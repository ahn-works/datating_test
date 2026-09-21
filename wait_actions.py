import urllib.request
import json
import time

url = 'https://api.github.com/repos/ahn-works/datating_test/actions/runs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})

print('Waiting for deployment to finish...')
while True:
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            latest_run = data['workflow_runs'][0]
            status = latest_run['status']
            if status == 'completed':
                print(f"Conclusion: {latest_run['conclusion']}")
                break
            time.sleep(10)
    except Exception as e:
        print(f'Error: {e}')
        time.sleep(10)
