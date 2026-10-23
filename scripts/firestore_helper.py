#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Firestore REST Client Helper (Zero-Dependency)
- Uses standard Python libraries (urllib, json, datetime) to interact with Firestore REST API.
- Converts Python native dict/list/primitives to/from Firestore JSON field structures seamlessly.
"""

import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone

FIRESTORE_PROJECT = os.environ.get("FIRESTORE_PROJECT", "test-b54fc")
FIRESTORE_WEB_KEY = os.environ.get("FIRESTORE_WEB_KEY", "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U")
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{FIRESTORE_PROJECT}/databases/(default)/documents"
USER_AGENT = "OOMU-Automation-Agent/2.0 (GitHubActions; Python 3.11)"


def python_to_firestore_value(val):
    """Converts a native Python value to Firestore REST API value format."""
    if val is None:
        return {"nullValue": None}
    elif isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": val}
    elif isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, datetime):
        return {"timestampValue": val.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [python_to_firestore_value(item) for item in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: python_to_firestore_value(v) for k, v in val.items()}}}
    else:
        return {"stringValue": str(val)}


def firestore_to_python_value(f_val):
    """Converts a Firestore REST API field value back into a native Python value."""
    if not isinstance(f_val, dict):
        return f_val

    if "stringValue" in f_val:
        return f_val["stringValue"]
    elif "integerValue" in f_val:
        try:
            return int(f_val["integerValue"])
        except ValueError:
            return f_val["integerValue"]
    elif "doubleValue" in f_val:
        return float(f_val["doubleValue"])
    elif "booleanValue" in f_val:
        return bool(f_val["booleanValue"])
    elif "timestampValue" in f_val:
        return f_val["timestampValue"]
    elif "nullValue" in f_val:
        return None
    elif "arrayValue" in f_val:
        values = f_val["arrayValue"].get("values", [])
        return [firestore_to_python_value(v) for v in values]
    elif "mapValue" in f_val:
        fields = f_val["mapValue"].get("fields", {})
        return {k: firestore_to_python_value(v) for k, v in fields.items()}
    return f_val


def document_to_dict(doc):
    """Unpacks a raw Firestore document JSON into a clean Python dictionary."""
    if not doc or "fields" not in doc:
        return {}
    res = {k: firestore_to_python_value(v) for k, v in doc["fields"].items()}
    if "name" in doc:
        res["_id"] = doc["name"].split("/")[-1]
        res["_path"] = doc["name"]
    if "createTime" in doc:
        res["_createTime"] = doc["createTime"]
    if "updateTime" in doc:
        res["_updateTime"] = doc["updateTime"]
    return res


def dict_to_document_fields(data):
    """Packs a standard Python dictionary into Firestore 'fields' format."""
    fields = {}
    for k, v in data.items():
        if k.startswith("_"):
            continue
        fields[k] = python_to_firestore_value(v)
    return fields


def get_document(collection_path, doc_id):
    """Retrieves a single Firestore document by collection and ID."""
    url = f"{BASE_URL}/{collection_path}/{doc_id}?key={FIRESTORE_WEB_KEY}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return document_to_dict(data)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise e


def list_documents(collection_path, page_size=100):
    """Lists documents in a collection."""
    url = f"{BASE_URL}/{collection_path}?key={FIRESTORE_WEB_KEY}&pageSize={page_size}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            docs = data.get("documents", [])
            return [document_to_dict(d) for d in docs]
    except Exception as e:
        print(f"[WARN] list_documents({collection_path}) error: {e}")
        return []


def set_document(collection_path, doc_id, data, merge=True):
    """Creates or overwrites/merges a document in Firestore."""
    url = f"{BASE_URL}/{collection_path}/{doc_id}?key={FIRESTORE_WEB_KEY}"
    fields = dict_to_document_fields(data)
    body = {"fields": fields}
    post_bytes = json.dumps(body).encode("utf-8")

    method = "PATCH" if merge else "PUT"
    req = urllib.request.Request(
        url,
        data=post_bytes,
        headers={"Content-Type": "application/json", "User-Agent": USER_AGENT},
        method=method,
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        return document_to_dict(res)


def create_document(collection_path, data):
    """Creates a document in a collection with an auto-generated ID."""
    url = f"{BASE_URL}/{collection_path}?key={FIRESTORE_WEB_KEY}"
    fields = dict_to_document_fields(data)
    body = {"fields": fields}
    post_bytes = json.dumps(body).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=post_bytes,
        headers={"Content-Type": "application/json", "User-Agent": USER_AGENT},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        return document_to_dict(res)


def delete_document(collection_path, doc_id):
    """Deletes a document from Firestore."""
    url = f"{BASE_URL}/{collection_path}/{doc_id}?key={FIRESTORE_WEB_KEY}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT}, method="DELETE")
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return True
    except Exception as e:
        print(f"[WARN] delete_document({collection_path}/{doc_id}) error: {e}")
        return False
