import os
import subprocess

result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, shell=True)
print(result.stdout)
print(result.stderr)
