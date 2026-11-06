import urllib.request
import json
import os
import sys

sys.path.append("scripts")
import sync_trends

def main():
    print("[1/4] Loading credentials from Firestore...")
    kopis_key, gemini_key, tour_key, kobis_key, r2_cfg = sync_trends.load_credentials_from_firestore()

    # Load Giphy API key from config/api_keys
    giphy_data = sync_trends.http_get_json(f"{sync_trends.BASE_FIRESTORE_URL}/config/api_keys?key={sync_trends.FIRESTORE_WEB_KEY}")
    giphy_key = giphy_data.get("fields", {}).get("giphyApiKey", {}).get("stringValue", "")
    if not giphy_key:
        print("[ERROR] giphyApiKey not found in config/api_keys")
        return

    print(f"[OK] Giphy API Key loaded: {giphy_key[:6]}...")

    # Fetch Top 100 Trending GIFs from Giphy (2 calls of 50 items)
    print("\n[2/4] Fetching Top 100 Trending GIFs from Giphy API (2 calls)...")
    url1 = f"https://api.giphy.com/v1/gifs/trending?api_key={giphy_key}&limit=50&offset=0&rating=g"
    url2 = f"https://api.giphy.com/v1/gifs/trending?api_key={giphy_key}&limit=50&offset=50&rating=g"
    res1 = sync_trends.http_get_json(url1)
    res2 = sync_trends.http_get_json(url2)
    data = res1.get("data", []) + res2.get("data", [])
    print(f"[OK] Fetched {len(data)} trending GIFs from Giphy")

    stickers = []
    total_bytes = 0

    print("\n[3/4] Downloading and uploading to Cloudflare R2 'stickers/' ...")
    for idx, item in enumerate(data):
        rank = idx + 1
        raw_id = item.get("id", f"gif_{rank}")
        title = item.get("title", f"인기 반응 {rank}")
        clean_title = title.replace(" GIF", "").strip() or f"인기 반응 {rank}위"

        images = item.get("images", {})
        # Pick fixed_height_small or fixed_width_small for mobile performance
        img_info = images.get("fixed_height_small") or images.get("fixed_height") or images.get("original")
        gif_url = img_info.get("url") if img_info else ""

        if not gif_url:
            continue

        # Download bytes
        img_bytes, ctype = sync_trends.download_image_bytes(gif_url)
        if not img_bytes:
            continue

        total_bytes += len(img_bytes)
        r2_key = f"stickers/popular_{rank:03d}_{raw_id}.gif"

        # Upload to R2
        r2_url = sync_trends.upload_bytes_to_r2_and_presign(img_bytes, ctype or "image/gif", r2_key, r2_cfg)
        final_url = sync_trends.to_cors_safe_https_url(gif_url)

        stickers.append({
            "rank": rank,
            "id": raw_id,
            "title": clean_title,
            "r2Key": r2_key,
            "url": final_url,
            "width": int(img_info.get("width", 150)),
            "height": int(img_info.get("height", 100)),
            "sizeBytes": len(img_bytes),
        })
        if rank % 10 == 0 or rank <= 5:
            print(f"  [{rank}/100] Uploaded {r2_key} ({len(img_bytes)//1024} KB): {clean_title[:30]}")

    print(f"\n[OK] All {len(stickers)} stickers processed. Total Size: {total_bytes / (1024*1024):.2f} MB")
    print(f"Cloudflare R2 Free 10GB Usage: {(total_bytes / (10 * 1024 * 1024 * 1024)) * 100:.4f}%")

    # [4/4] Save stickers catalog to Firestore config/curated_stickers
    print("\n[4/4] Saving stickers catalog to Firestore 'config/curated_stickers'...")
    firestore_values = []
    for s in stickers:
        firestore_values.append({
            "mapValue": {
                "fields": {
                    "rank": {"integerValue": s["rank"]},
                    "id": {"stringValue": s["id"]},
                    "title": {"stringValue": s["title"]},
                    "url": {"stringValue": s["url"]},
                    "r2Key": {"stringValue": s["r2Key"]},
                    "width": {"integerValue": s["width"]},
                    "height": {"integerValue": s["height"]},
                }
            }
        })

    fields = {
        "count": {"integerValue": len(stickers)},
        "totalMegabytes": {"doubleValue": round(total_bytes / (1024*1024), 2)},
        "r2PercentOf10Gb": {"doubleValue": round((total_bytes / (10 * 1024 * 1024 * 1024)) * 100, 4)},
        "updatedAt": {"timestampValue": sync_trends.datetime.now(sync_trends.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")},
        "stickers": {"arrayValue": {"values": firestore_values}},
    }
    sync_trends.http_patch_firestore("config/curated_stickers", fields)
    print(f"[SUCCESS] config/curated_stickers updated successfully with {len(stickers)} stickers in Firestore!")

if __name__ == "__main__":
    main()
