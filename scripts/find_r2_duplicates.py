# -*- coding: utf-8 -*-
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import boto3
from scripts.firestore_helper import get_document, list_documents

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

print(f"Connecting to Cloudflare R2 [{bucket_name}]...")
paginator = s3.get_paginator('list_objects_v2')
pages = paginator.paginate(Bucket=bucket_name)

objects = []
for page in pages:
    for item in page.get('Contents', []):
        objects.append({
            'key': item['Key'],
            'size': item['Size'],
            'etag': item['ETag'].strip('"'),
            'last_modified': item['LastModified'],
        })

print(f"Total objects found: {len(objects)}")

# 1. Group by ETag (Content MD5 Hash)
by_etag = {}
for obj in objects:
    etag = obj['etag']
    by_etag.setdefault(etag, []).append(obj)

exact_duplicates = {etag: objs for etag, objs in by_etag.items() if len(objs) > 1}

print(f"\n--- [1] Exact Content Duplicates (Same MD5/ETag) ---")
if exact_duplicates:
    print(f"Found {len(exact_duplicates)} groups of identical files:")
    for etag, objs in exact_duplicates.items():
        print(f"\nETag: {etag} (Count: {len(objs)})")
        for o in objs:
            print(f"  - {o['key']} ({o['size']/1024:.1f} KB, {o['last_modified']})")
else:
    print("No exact identical files found by ETag.")

# 2. Group by file size
by_size = {}
for obj in objects:
    size = obj['size']
    by_size.setdefault(size, []).append(obj)

size_matches = {size: objs for size, objs in by_size.items() if len(objs) > 1}
print(f"\n--- [2] Files with Identical Size (Potential Duplicates) ---")
for size, objs in size_matches.items():
    print(f"Size {size} bytes ({size/1024:.1f} KB): {len(objs)} files")
    for o in objs:
        print(f"  - {o['key']} (ETag: {o['etag']})")

# 3. Check Firestore References
print("\n--- [3] Checking Firestore References Across All Collections ---")
collections_to_check = ['users', 'meetups', 'community_posts', 'trend_events', 'chatRooms', 'reviews']
all_firestore_urls = set()
firestore_references_map = {}

for col in collections_to_check:
    docs = list_documents(col)
    print(f"Collection '{col}': {len(docs)} documents")
    for doc_item in docs:
        doc_id = doc_item.get('id', doc_item.get('uid', 'unknown'))
        for k, v in doc_item.items():
            if isinstance(v, str) and ('.r2.cloudflarestorage.com' in v or 'posters/' in v or 'profiles/' in v or 'oomu-spot' in v):
                all_firestore_urls.add(v)
                firestore_references_map.setdefault(v, []).append(f"{col}/{doc_id}.{k}")
            elif isinstance(v, list):
                for item in v:
                    if isinstance(item, str) and ('.r2.cloudflarestorage.com' in item or 'posters/' in item or 'profiles/' in item or 'oomu-spot' in item):
                        all_firestore_urls.add(item)
                        firestore_references_map.setdefault(item, []).append(f"{col}/{doc_id}.{k}[]")

print(f"Total unique R2 URLs referenced in Firestore: {len(all_firestore_urls)}")

referenced_keys = {}
unreferenced_keys = []

for obj in objects:
    key = obj['key']
    matched_refs = []
    for url, refs in firestore_references_map.items():
        if key in url:
            matched_refs.extend(refs)
    if matched_refs:
        referenced_keys[key] = {
            'obj': obj,
            'refs': matched_refs
        }
    else:
        unreferenced_keys.append(obj)

print(f"\n[SUMMARY]")
print(f"Total Objects in R2: {len(objects)}")
print(f"Referenced in Firestore: {len(referenced_keys)}")
print(f"Unreferenced in Firestore: {len(unreferenced_keys)}")

print("\n--- [4] Referenced Files in Firestore ---")
for key, data in referenced_keys.items():
    print(f"  [KEEP] {key} ({data['obj']['size']/1024:.1f} KB) -> {', '.join(data['refs'])}")

print("\n--- [5] Unreferenced Stale Files (Candidates for Deletion) ---")
for obj in unreferenced_keys:
    print(f"  [DELETE] {obj['key']} ({obj['size']/1024:.1f} KB, uploaded: {obj['last_modified']})")

