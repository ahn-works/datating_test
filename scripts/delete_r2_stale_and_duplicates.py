# -*- coding: utf-8 -*-
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import boto3
from scripts.firestore_helper import get_document, list_documents

# 1. Load R2 Config
doc = get_document('config', 'r2_storage')
if not doc:
    print('Error: config/r2_storage not found in Firestore')
    sys.exit(1)

account_id = doc.get('accountId')
access_key = doc.get('accessKeyId')
secret_key = doc.get('secretAccessKey')
bucket_name = doc.get('bucketName', 'oomu-spot')
endpoint_url = f"https://{account_id}.r2.cloudflarestorage.com"

s3 = boto3.client(
    's3',
    endpoint_url=endpoint_url,
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    region_name='auto',
)

print(f"Connected to Cloudflare R2 [{bucket_name}].")

# 2. Get all active Firestore image references
collections_to_check = ['users', 'meetups', 'community_posts', 'trend_events', 'chatRooms', 'reviews']
all_firestore_refs = set()

for col in collections_to_check:
    docs = list_documents(col)
    for d in docs:
        for k, v in d.items():
            if isinstance(v, str) and ('.r2.cloudflarestorage.com' in v or 'posters/' in v or 'profiles/' in v or 'oomu-spot' in v):
                all_firestore_refs.add(v)
            elif isinstance(v, list):
                for item in v:
                    if isinstance(item, str) and ('.r2.cloudflarestorage.com' in item or 'posters/' in item or 'profiles/' in item or 'oomu-spot' in item):
                        all_firestore_refs.add(item)

# 3. List all R2 objects
paginator = s3.get_paginator('list_objects_v2')
pages = paginator.paginate(Bucket=bucket_name)

all_objects = []
for page in pages:
    for item in page.get('Contents', []):
        all_objects.append(item)

total_initial_count = len(all_objects)
total_initial_size = sum(item['Size'] for item in all_objects)

print(f"Initial State: {total_initial_count} objects, {total_initial_size / (1024*1024):.2f} MB")

# 4. Filter objects to keep vs delete
to_keep = []
to_delete = []

for obj in all_objects:
    key = obj['Key']
    is_referenced = any(key in ref for ref in all_firestore_refs)
    if is_referenced:
        to_keep.append(obj)
    else:
        to_delete.append(obj)

print(f"\nObjects to Keep (Active): {len(to_keep)}")
for o in to_keep:
    print(f"  [KEEP] {o['Key']} ({o['Size']/1024:.1f} KB)")

print(f"\nObjects to Delete (Stale/Duplicate): {len(to_delete)}")
for o in to_delete:
    print(f"  [DELETE] {o['Key']} ({o['Size']/1024:.1f} KB)")

if not to_delete:
    print("\nNo unreferenced or duplicate objects found. Bucket is clean!")
    sys.exit(0)

# Safety check: Must keep at least 15 active files
if len(to_keep) < 15:
    print(f"\n[ABORT] Safety check failed: Only {len(to_keep)} active files found. Expected >= 15.")
    sys.exit(1)

# 5. Delete in batches of up to 1000
delete_payload = [{'Key': o['Key']} for o in to_delete]
print(f"\nProceeding to delete {len(delete_payload)} objects from R2...")

response = s3.delete_objects(
    Bucket=bucket_name,
    Delete={'Objects': delete_payload, 'Quiet': False}
)

deleted_list = response.get('Deleted', [])
errors_list = response.get('Errors', [])

print(f"\n[RESULT]")
print(f"Successfully deleted: {len(deleted_list)} objects")
if errors_list:
    print(f"Errors encountered: {len(errors_list)}")
    for err in errors_list:
        print(f"  Error deleting {err.get('Key')}: {err.get('Code')} - {err.get('Message')}")

# 6. Verify post-deletion state
res_after = s3.list_objects_v2(Bucket=bucket_name)
after_objects = res_after.get('Contents', [])
total_after_count = len(after_objects)
total_after_size = sum(item['Size'] for item in after_objects)

print(f"\nPost-Deletion State:")
print(f"Objects: {total_initial_count} -> {total_after_count} (Reduced by {total_initial_count - total_after_count})")
print(f"Total Size: {total_initial_size / (1024*1024):.2f} MB -> {total_after_size / (1024*1024):.2f} MB (Freed {(total_initial_size - total_after_size)/(1024*1024):.2f} MB)")

