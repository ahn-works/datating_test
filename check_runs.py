import urllib.request, json
url = 'https://api.github.com/repos/ahn-works/datating_test/actions/runs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
runs = json.loads(urllib.request.urlopen(req).read())['workflow_runs']
for run in runs[:5]:
    print(f"{run['id']} - {run['status']} - {run['conclusion']} - {run['created_at']}")
