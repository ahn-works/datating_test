import os
import re

lib_dir = "lib"
files_missing_services = []

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            p = os.path.join(root, f)
            with open(p, "r", encoding="utf-8", errors="ignore") as fp:
                content = fp.read()
            if "HapticFeedback" in content:
                if "package:flutter/services.dart" not in content and "services.dart" not in content:
                    files_missing_services.append(p)

print("Files using HapticFeedback without importing services.dart:")
for f in files_missing_services:
    print(f" - {f}")
