---
description: Always extract features, create a checklist, and report progress when creating a new UI.
---

# UI Implementation Workflow Rule

Whenever you are asked to create or modify a UI screen based on a design or user request, you MUST follow this format in your response:

1. **기능 추출 및 체크리스트 (Feature Extraction & Checklist)**: 
   List all the features identified from the design/request using markdown checkboxes.
2. **진행 상태 (Progress Status)**:
   Explicitly state the current progress (e.g., 100% 완료, 50% 진행 중) and which items are done.
3. **QA 검증 (QA Verification)**:
   Confirm that the code has been successfully pushed and deployed (GitHub Actions Success) before claiming 100% completion.

Always adapt text dynamically based on the context (e.g., changing 'Driver Review' to 'Host Review' for non-driving gatherings, and ensuring no illegal 'settlement/money' text is included).
