import io
import re

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_menu = """            children: [
              _buildAttachmentIcon(Icons.image, '사진보내기', Colors.green),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)),
            ],"""

new_menu = """            children: [
              _buildAttachmentIcon(Icons.image, '사진', Colors.green),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)),
              _buildAttachmentIcon(Icons.local_cafe, '핫플 공유', Colors.brown),
              _buildAttachmentIcon(Icons.directions_car, '카풀 요청', Colors.indigo),
              _buildAttachmentIcon(Icons.contact_emergency, '안전귀가', Colors.pink),
              _buildAttachmentIcon(Icons.badge, '프로필 교환', Colors.teal),
            ],"""

content = content.replace(old_menu, new_menu)

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
