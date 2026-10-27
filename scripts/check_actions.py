import urllib.request
import json
import sys
import time

import subprocess

url = "https://api.github.com/repos/ahn-works/datating_test/actions/runs?per_page=10"
headers = {"User-Agent": "Mozilla/5.0"}
if len(sys.argv) > 1:
    target_sha = sys.argv[1][:8]
else:
    try:
        target_sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode("utf-8").strip()[:8]
    except Exception:
        target_sha = "8f1b9e12"

def fetch_runs():
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("workflow_runs", [])
    except Exception as e:
        print(f"Error fetching runs: {e}")
        return []

def main():
    print(f"Monitoring GitHub Actions for commit {target_sha}...")
    start_time = time.time()
    max_duration = 360  # 6 minutes

    while True:
        runs = fetch_runs()
        matching = [r for r in runs if r["head_sha"].startswith(target_sha)]
        
        if not matching:
            print("No matching runs found yet...")
        else:
            all_done = True
            print("-" * 50)
            print(f"Elapsed: {int(time.time() - start_time)}s")
            for r in matching:
                name = r["name"]
                run_num = r["run_number"]
                status = r["status"]
                conclusion = r["conclusion"]
                html_url = r["html_url"]
                print(f"[{status.upper()}] {name} (#{run_num}) -> {conclusion or 'running'} ({html_url})")
                if status != "completed":
                    all_done = False
            
            if all_done:
                print("\n[ALL WORKFLOWS COMPLETED]")
                conclusions = [r["conclusion"] for r in matching]
                if all(c == "success" for c in conclusions):
                    print(">>> SUCCESS: All workflows completed with green checkmark (success)! <<<")
                    sys.exit(0)
                else:
                    print(">>> Some workflows did not succeed. Check conclusions above. <<<")
                    sys.exit(1)

        if time.time() - start_time > max_duration:
            print(f"Timeout reached ({max_duration}s). Still running.")
            sys.exit(2)

        time.sleep(15)

if __name__ == "__main__":
    main()
