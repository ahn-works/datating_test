import sys
import os
from datetime import datetime, timezone

sys.path.append('scripts')
import sync_trends

def main():
    kopis_key, gemini_key, _tour_key, kobis_key, r2_cfg = sync_trends.load_credentials_from_firestore()

    # 1. Fetch sports
    sports = sync_trends.fetch_kbo_and_kleague_trends()
    print(f"[OK] Fetched {len(sports)} sports events")

    # 2. Fetch movies
    movies = sync_trends.fetch_kobis_boxoffice_movies(kobis_key)
    print(f"[OK] Fetched {len(movies)} movie events")

    # 3. Ensure crawled posters and R2 upload
    for s in sports:
        sync_trends.ensure_crawled_poster(s, kopis_key, r2_cfg)
    for m in movies:
        sync_trends.ensure_crawled_poster(m, kopis_key, r2_cfg)

    # 4. Write to Firestore trend_events directly
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    all_new = sports + movies

    for idx, item in enumerate(all_new):
        doc_id = item.get("id")
        fields = {
            "title": {"stringValue": item.get("title", "")},
            "category": {"stringValue": item.get("category", "")},
            "location": {"stringValue": item.get("venue") or item.get("location", "")},
            "tag": {"stringValue": item.get("tag", "")},
            "vibe": {"stringValue": item.get("vibe", "활기찬")},
            "poster": {"stringValue": item.get("poster", "")},
            "originalPoster": {"stringValue": item.get("originalPoster", "")},
            "posterR2Url": {"stringValue": item.get("posterR2Url", "")},
            "posterR2Key": {"stringValue": item.get("posterR2Key", "")},
            "period": {"stringValue": item.get("period", "")},
            "genre": {"stringValue": item.get("genre", "스포츠" if "스포츠" in item.get("category", "") else "영화")},
            "rank": {"integerValue": int(item.get("rank", 20 + idx))},
            "updatedAt": {"timestampValue": now_iso},
        }
        sync_trends.http_patch_firestore(f"trend_events/{doc_id}", fields)
        print(f"Synced trend_events/{doc_id}: {item.get('title')}")

    print("\n[SUCCESS] All sports and movie events successfully written to Firestore!")

if __name__ == "__main__":
    main()

