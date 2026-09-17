import io

with io.open('C:/Users/DT4/.gemini/antigravity/brain/0001307e-ea31-4a61-a8c6-e16945f31ff5/pending_features.md', 'r', encoding='utf-8') as f:
    text = f.read()

new_section = '''
## 📝 3번 화면: 여행 모임 등록 (Host Screen)
| 기능 명칭 | 현재 상태 | 추후 필요 작업 |
| :--- | :--- | :--- |
| **상단 헤더 둥근 '지역 선택' 드롭다운** | UI 뱃지만 존재 | 클릭 시 타 지역(예: 서교동, 망원동)을 검색/선택하는 바텀 시트 기획 필요 |
| **출발 장소 및 목적지 '검색' 아이콘** | UI 폼만 존재 | 클릭 시 카카오맵/네이버지도 기반 장소 검색 모달 기획 필요 |
| **출발 일시 및 복귀 예정 '달력/시계' 아이콘** | UI 폼만 존재 | 클릭 시 날짜(Calendar) 및 시간(Time) 픽커 팝업 기획 필요 |
'''

with io.open('C:/Users/DT4/.gemini/antigravity/brain/0001307e-ea31-4a61-a8c6-e16945f31ff5/pending_features.md', 'w', encoding='utf-8') as f:
    f.write(text + new_section)