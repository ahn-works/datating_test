import os
import sys
import zipfile
import hashlib
import json
import tempfile
import shutil
from datetime import datetime
from pathlib import Path

def get_file_sha256(filepath):
    h = hashlib.sha256()
    with open(filepath, 'rb') as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def create_and_verify_backup():
    project_dir = Path(r"C:\Users\DT4\Downloads\oomu_app").resolve()
    parent_dir = project_dir.parent
    backup_base_dir = parent_dir / "oomu_app_backups"
    backup_base_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    zip_filename = f"oomu_app_before_ai_{timestamp}.zip"
    zip_path = backup_base_dir / zip_filename
    manifest_path = backup_base_dir / f"oomu_app_before_ai_{timestamp}_manifest.json"
    excluded_path = backup_base_dir / f"oomu_app_before_ai_{timestamp}_excluded.txt"

    # Excluded directories (regenerable caches and build outputs)
    EXCLUDED_DIR_NAMES = {
        'build',
        '.dart_tool',
        '.gradle', # inside android/.gradle
        'node_modules',
        'oomu_app_backups',
        'backups' # skip existing local backups directory if redundant, or let's inspect backups dir
    }

    # Specifically targeted excluded paths relative to project root
    def is_excluded(rel_path_str, is_dir=False):
        parts = rel_path_str.replace('\\', '/').split('/')
        if 'build' in parts:
            return True, "build cache"
        if '.dart_tool' in parts:
            return True, ".dart_tool cache"
        if 'android' in parts and '.gradle' in parts:
            return True, "android/.gradle cache"
        if 'node_modules' in parts:
            return True, "node_modules cache"
        if parts[0] == 'backups':
            return True, "nested internal backups dir"
        return False, None

    print(f"[*] Scanning project directory: {project_dir}")
    files_to_pack = []
    excluded_items = []

    for root, dirs, files in os.walk(project_dir, followlinks=False):
        rel_root = os.path.relpath(root, project_dir)
        
        # Check if current directory should be excluded
        if rel_root != '.':
            excluded, reason = is_excluded(rel_root, is_dir=True)
            if excluded:
                excluded_items.append(f"[DIR] {rel_root} ({reason})")
                dirs[:] = [] # Do not recurse into excluded directory
                continue

        for f in files:
            full_path = Path(root) / f
            rel_file = os.path.relpath(full_path, project_dir)
            
            # Check symbolic links
            if full_path.is_symlink():
                excluded_items.append(f"[SYMLINK] {rel_file} (symlink not traversed)")
                continue

            excluded, reason = is_excluded(rel_file)
            if excluded:
                excluded_items.append(f"[FILE] {rel_file} ({reason})")
                continue

            try:
                size = full_path.stat().st_size
                sha256 = get_file_sha256(full_path)
                files_to_pack.append({
                    "rel_path": rel_file.replace('\\', '/'),
                    "full_path": str(full_path),
                    "size": size,
                    "sha256": sha256
                })
            except Exception as e:
                print(f"[ERROR] Failed to read {full_path}: {e}")
                sys.exit(1)

    print(f"[*] Total files to back up: {len(files_to_pack)}")
    print(f"[*] Total excluded items: {len(excluded_items)}")

    # Write manifest and excluded lists
    with open(excluded_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(excluded_items))

    # Create ZIP archive
    print(f"[*] Creating ZIP archive: {zip_path}")
    with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as zipf:
        for item in files_to_pack:
            zipf.write(item["full_path"], arcname=item["rel_path"])

    zip_size = zip_path.stat().st_size
    zip_sha256 = get_file_sha256(zip_path)

    # Save manifest next to ZIP
    manifest_data = {
        "project_dir": str(project_dir),
        "backup_zip": str(zip_path),
        "backup_timestamp": timestamp,
        "zip_size_bytes": zip_size,
        "zip_sha256": zip_sha256,
        "file_count": len(files_to_pack),
        "files": files_to_pack
    }
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest_data, f, indent=2, ensure_ascii=False)

    print("[*] Verifying ZIP integrity with testzip()...")
    with zipfile.ZipFile(zip_path, 'r') as zipf:
        bad_file = zipf.testzip()
        if bad_file:
            print(f"[FATAL] Corrupted file in archive: {bad_file}")
            sys.exit(1)
    print("    -> testzip() passed with 0 corruptions.")

    # Unpack to temporary directory and verify SHA-256
    print("[*] Unpacking to temporary directory for full roundtrip verification...")
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        with zipfile.ZipFile(zip_path, 'r') as zipf:
            zipf.extractall(tmp_path)

        verified_count = 0
        for item in files_to_pack:
            extracted_file = tmp_path / item["rel_path"]
            if not extracted_file.exists():
                print(f"[FATAL] Missing file after extraction: {item['rel_path']}")
                sys.exit(1)
            extracted_sha = get_file_sha256(extracted_file)
            if extracted_sha != item["sha256"]:
                print(f"[FATAL] Hash mismatch for {item['rel_path']}! Orig: {item['sha256']}, Extracted: {extracted_sha}")
                sys.exit(1)
            verified_count += 1

        print(f"    -> Extracted {verified_count}/{len(files_to_pack)} files. All hashes match 100% perfectly!")

    result_summary = {
        "status": "SUCCESS",
        "zip_path": str(zip_path),
        "zip_size_bytes": zip_size,
        "zip_size_mb": round(zip_size / (1024 * 1024), 2),
        "file_count": len(files_to_pack),
        "zip_sha256": zip_sha256,
        "manifest_path": str(manifest_path),
        "excluded_path": str(excluded_path)
    }
    print(json.dumps(result_summary, indent=2, ensure_ascii=False))

if __name__ == '__main__':
    create_and_verify_backup()
