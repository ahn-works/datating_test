import urllib.request
import json
import zipfile
import io
import sys
import os

run_id = sys.argv[1]
url = f"https://api.github.com/repos/ahn-works/datating_test/actions/runs/{run_id}/logs"

try:
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as response:
        with zipfile.ZipFile(io.BytesIO(response.read())) as z:
            # print list of files
            print("Files in zip:", z.namelist())
            for name in z.namelist():
                if "build" in name.lower():
                    print(f"--- {name} ---")
                    lines = z.read(name).decode('utf-8', errors='ignore').split('\n')
                    for line in lines:
                        if "Error" in line or "error:" in line or "Exception" in line or "Failed" in line:
                            print(line)
except Exception as e:
    print(f"Failed to fetch logs: {e}")
