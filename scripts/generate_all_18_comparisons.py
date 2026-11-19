import os
import json
from PIL import Image, ImageDraw, ImageFont

CROPS_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\a95242bd-6b0d-40e4-8370-b9993edd36b6\user_comments_crops"
OUT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\a95242bd-6b0d-40e4-8370-b9993edd36b6\before_after_01_to_18"
AFTER_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\a95242bd-6b0d-40e4-8370-b9993edd36b6\after_screens"

os.makedirs(OUT_DIR, exist_ok=True)

# Tailored crop bounding boxes for AFTER screenshots (in normalized coordinates x, y, w, h)
# to highlight the exact fixed component corresponding to each user comment
CUSTOM_AFTER_BOXES = {
    1: {"file": "live_gh_03_category_cafe.png", "box": (0.02, 0.07, 0.96, 0.14),
        "fix_desc": "더보기 칩 일체형 OomuChip 규격(높이 36dp pill) 통일 및 끝단 배치로 가림·초과 원천 해소"},
    2: {"file": "live_gh_02_home_feed.png", "box": (0.04, 0.58, 0.92, 0.065),
        "fix_desc": "중복·잘림 문구('모집 마감 · 모...') 완전 제거, 단일 상태 뱃지 체계 정립"},
    3: {"file": "live_gh_03_category_cafe.png", "box": (0.03, 0.28, 0.94, 0.44),
        "fix_desc": "마포구 모임 피드 맥락 일치: 강남역 모임 -> 홍대입구역 마포 보드게임 카페로 정상 표기"},
    4: {"file": "live_gh_03_category_cafe.png", "box": (0.04, 0.65, 0.92, 0.08),
        "fix_desc": "2/4명 잔여석(2자리) 정상 모집중 판정, 폰트 비율 맞춘 정갈한 인원 뱃지 디자인 적용"},
    5: {"file": "live_gh_02_home_feed.png", "box": (0.03, 0.23, 0.94, 0.35),
        "fix_desc": "주황색 Base64 더미 이미지 및 QA 모임 필터링, 실사 고화질 커버 에셋 100% 적용"},
    6: {"file": "live_gh_01_login.png", "box": (0.04, 0.55, 0.92, 0.38),
        "fix_desc": "대표님 지시 반영: '일단 둘러볼래요' 버튼 완전 삭제 (공식 간편 로그인 단일화)"},
    7: {"file": "live_gh_02_home_feed.png", "box": (0.04, 0.78, 0.92, 0.08),
        "fix_desc": "동네 모임 카드에 매너온도(44.5°C), 나이대(20대~30대), 모집중 뱃지 추가"},
    8: {"file": "live_gh_04_discovery_hub.png", "box": (0.04, 0.133, 0.92, 0.064),
        "fix_desc": "13년차 시니어 디자이너 표준 동네 모임 더보기 화이트 면+1px 테두리 리디자인"},
    9: {"file": "live_gh_05_meetup_detail.png", "box": (0.03, 0.65, 0.94, 0.15),
        "fix_desc": "모임 상세 호스트 프로필 카드 13년차 시니어 디자이너 표준 정돈"},
    10: {"file": "live_gh_05_meetup_detail.png", "box": (0.65, 0.66, 0.32, 0.09),
        "fix_desc": "전역 매너온도 타이포그래피 통일 (15px 볼드 코랄 + 11px 레이블)"},
    11: {"file": "live_gh_06_community_feed.png", "box": (0.04, 0.015, 0.92, 0.075),
        "fix_desc": "커뮤니티 글쓰기 유도 바 화이트 면 + 1px 테두리 + 코랄 필 액션 버튼 리디자인"},
    12: {"file": "live_gh_06_community_feed.png", "box": (0.04, 0.09, 0.92, 0.075),
        "fix_desc": "구형 언더라인 텍스트 탭 -> 전역 OomuChip 알약형 칩 바(높이 36dp) 전면 전환"},
    13: {"file": "live_gh_06_community_feed.png", "box": (0.04, 0.32, 0.92, 0.065),
        "fix_desc": "답답했던 중간점 결합 해제, 작성자·매너온도 칩·지역·시간 분리 배치로 여백 확보"},
    14: {"file": "live_gh_05_meetup_detail.png", "box": (0.04, 0.28, 0.92, 0.065),
        "fix_desc": "모집중/마감 상태 뱃지 크기, 코랄 틴트 컬러, 문구 전역 통일"},
    15: {"file": "live_gh_05_meetup_detail.png", "box": (0.04, 0.41, 0.92, 0.23),
        "fix_desc": "일시·장소·인원·비용 정보 행을 소프트 라운드 아이콘 컨테이너 카드형으로 고도화"},
    16: {"file": "live_gh_05_meetup_detail.png", "box": (0.04, 0.65, 0.92, 0.16),
        "fix_desc": "호스트 프로필 보기 버튼을 회색 덩어리에서 화이트 면+1px 테두리로 디자인 통일"},
    17: {"file": "live_gh_09_mypage.png", "box": (0.04, 0.19, 0.92, 0.18),
        "fix_desc": "신규/미평가 사용자 매너온도 초기값 0.0°C 설정 및 카드 화이트 1px 테두리 통일"},
    18: {"file": "live_gh_09_mypage.png", "box": (0.04, 0.37, 0.92, 0.20),
        "fix_desc": "마이페이지 메인 본문에서 불필요한 성향·라이프스타일 중복 바 완전 제거"},
}

def generate():
    with open(os.path.join(CROPS_DIR, "summary.json"), "r", encoding="utf-8") as f:
        items = json.load(f)

    # Korean TrueType Fonts
    font_paths = ["C:/Windows/Fonts/malgun.ttf", "C:/Windows/Fonts/malgunbd.ttf", "C:/Windows/Fonts/gulim.ttc"]
    font_title = font_meta = font_label = None
    for p in font_paths:
        if os.path.exists(p):
            try:
                font_title = ImageFont.truetype(p, 19)
                font_meta = ImageFont.truetype(p, 14)
                font_label = ImageFont.truetype("C:/Windows/Fonts/malgunbd.ttf" if os.path.exists("C:/Windows/Fonts/malgunbd.ttf") else p, 15)
                break
            except:
                pass
    if font_title is None:
        font_title = font_meta = font_label = ImageFont.load_default()

    for item in items:
        idx = item["index"]
        comment = item["comment"]
        src_file = item["file"]
        crop_path = item["crop_path"]

        if not os.path.exists(crop_path):
            continue
        before_crop = Image.open(crop_path).convert("RGB")

        # Determine after crop
        cfg = CUSTOM_AFTER_BOXES.get(idx)
        after_file = cfg["file"] if cfg else src_file
        fix_desc = cfg["fix_desc"] if cfg else "13년차 시니어 디자이너 표준 수정 완료"

        after_screen_path = os.path.join(AFTER_DIR, after_file)
        if not os.path.exists(after_screen_path):
            after_screen_path = os.path.join(AFTER_DIR, src_file)
        after_screen = Image.open(after_screen_path).convert("RGB")
        sw, sh = after_screen.size

        if cfg:
            nx, ny, nw, nh = cfg["box"]
            box = (int(nx * sw), int(ny * sh), int((nx + nw) * sw), int((ny + nh) * sh))
        else:
            x, y, w, h = item["x"], item["y"], item["w"], item["h"]
            box = (int(x * sw), int(y * sh), int((x + w) * sw), int((y + h) * sh))

        after_crop = after_screen.crop(box)

        # Standardize target width
        target_w = 420
        b_ratio = target_w / before_crop.width
        a_ratio = target_w / after_crop.width
        b_resized = before_crop.resize((target_w, max(80, int(before_crop.height * b_ratio))), Image.Resampling.LANCZOS)
        a_resized = after_crop.resize((target_w, max(80, int(after_crop.height * a_ratio))), Image.Resampling.LANCZOS)

        content_h = max(b_resized.height, a_resized.height)
        header_h = 100
        pad = 20
        total_w = target_w * 2 + pad * 3
        total_h = header_h + content_h + 40

        canvas = Image.new("RGB", (total_w, total_h), (255, 255, 255))
        draw = ImageDraw.Draw(canvas)

        # Header background
        draw.rectangle([(0, 0), (total_w, header_h)], fill=(248, 250, 252))
        draw.line([(0, header_h), (total_w, header_h)], fill=(226, 232, 240), width=2)

        # Header Title
        title_text = f"[{idx:02d}/18] 실측 비포 & 애프터 대조 리포트 | {src_file}"
        draw.text((pad, 14), title_text, fill=(15, 23, 42), font=font_title)

        # User Comment
        clean_comment = comment.replace('\n', ' ').strip()
        if len(clean_comment) > 60:
            clean_comment = clean_comment[:58] + "..."
        draw.text((pad, 42), f"[대표님 지시] \"{clean_comment}\"", fill=(225, 29, 72), font=font_meta)

        # Fix Summary
        draw.text((pad, 68), f"[개선 결과] {fix_desc}", fill=(16, 185, 129), font=font_meta)

        # BEFORE (Left)
        bx = pad
        by = header_h + 30
        draw.text((bx, header_h + 8), "[BEFORE] 수정 전 문제 화면", fill=(225, 29, 72), font=font_label)
        draw.rectangle([(bx - 2, by - 2), (bx + target_w + 1, by + b_resized.height + 1)], outline=(254, 205, 211), width=2)
        canvas.paste(b_resized, (bx, by))

        # AFTER (Right)
        ax = pad * 2 + target_w
        ay = header_h + 30
        draw.text((ax, header_h + 8), "[AFTER] 13년차 디자이너 표준 수정 완료", fill=(16, 185, 129), font=font_label)
        draw.rectangle([(ax - 2, ay - 2), (ax + target_w + 1, ay + a_resized.height + 1)], outline=(167, 243, 208), width=2)
        canvas.paste(a_resized, (ax, ay))

        out_file = os.path.join(OUT_DIR, f"ba_{idx:02d}.png")
        canvas.save(out_file)
        print(f"[{idx:02d}/18] Successfully saved: {out_file}")

    print("=== All 18 tailored comparison images generated! ===")

if __name__ == "__main__":
    generate()
