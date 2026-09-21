import urllib.request
import json
import time

url = 'https://api.github.com/repos/ahn-works/datating_test/actions/runs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        
        if 'workflow_runs' in data and len(data['workflow_runs']) > 0:
            runs = data['workflow_runs'][:3]
            for run in runs:
                print(f"ID: {run['id']}, Status: {run['status']}, Conclusion: {run['conclusion']}, Msg: {run['head_commit']['message'].splitlines()[0]}")
        else:
            print('No workflow runs found.')
except Exception as e:
    print(f'Error: {e}')
