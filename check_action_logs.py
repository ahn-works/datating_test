import urllib.request
import json
import zipfile
import io
import os

url = 'https://api.github.com/repos/ahn-works/datating_test/actions/runs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})

with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())
    latest_run = data['workflow_runs'][0]
    run_id = latest_run['id']
    jobs_url = latest_run['jobs_url']

req2 = urllib.request.Request(jobs_url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req2) as res2:
    jobs_data = json.loads(res2.read().decode())
    job = jobs_data['jobs'][0]
    print(f"Failed job step: {job['name']}")
    for step in job['steps']:
        if step['conclusion'] == 'failure':
            print(f"Failed step: {step['name']}")
