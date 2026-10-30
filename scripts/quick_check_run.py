import urllib.request, json
req = urllib.request.Request('https://api.github.com/repos/ahn-works/datating_test/actions/runs?per_page=3', headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as resp:
    data = json.loads(resp.read().decode('utf-8'))
    for r in data.get('workflow_runs', []):
        print(f"{r['name']}: {r['status']} ({r.get('conclusion')}) | SHA: {r['head_sha'][:8]}")

