import io
import re

def update_file(filepath, callback):
    with io.open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = callback(content)
    with io.open(filepath, 'w', encoding='utf-8', newline='\n') as f:
        f.write(new_content)

def update_profile_edit(content):
    # Add new lists
    new_lists = """  final List<String> _availableHobbies = ['맛집탐방', '러닝', '전시회', '와인', '드라이브', '캠핑', '보드게임', '방탈출', '뮤지컬', '카페투어'];
  final List<String> _availableCloseFriendPersonalities = [
    '또라이', '장난꾸러기', '화끈함', '분위기 메이커', '조용히 챙겨주는', '팩폭러', '리액션 봇', '순둥이', 
    '텐션 폭발', '어색함 제로', '은은한 광기', '다정다감', '츤데레', '허당', '고민 상담소', '선넘는 장난', '솔직함 100%'
  ];
  final List<String> _availableValues = [
    '신중한', '예의바른', '대화가 잘 통하는', '책임감 있는', '배려심 깊은', '자기계발', '긍정적인', '솔직함', 
    '도전적인', '여유로운', '약속을 잘 지키는', '감사할 줄 아는', '유머러스한', '독립적인', '가족적인', 
    '성실한', '편견 없는', '공감 능력이 뛰어난', '도덕적인', '신뢰할 수 있는'
  ];"""
    content = re.sub(r"final List<String> _availableHobbies = \[.*?\];", new_lists, content, flags=re.DOTALL)
    
    # Add variables for state
    state_vars = """  List<String> _hobbies = [];
  List<String> _closeFriendPersonalities = [];
  List<String> _values = [];"""
    content = content.replace("List<String> _hobbies = [];", state_vars)

    # Load data
    load_logic = """          _hobbies = List<String>.from(data['hobbies'] ?? []);
          _closeFriendPersonalities = List<String>.from(data['closeFriendPersonalities'] ?? []);
          _values = List<String>.from(data['values'] ?? []);"""
    content = content.replace("_hobbies = List<String>.from(data['hobbies'] ?? []);", load_logic)

    # Save data
    save_logic = """      'hobbies': _hobbies,
      'closeFriendPersonalities': _closeFriendPersonalities,
      'values': _values,"""
    content = content.replace("'hobbies': _hobbies,", save_logic)

    # Add to UI builder
    ui_blocks = """            _buildSectionTitle('나의 관심사 / 취향'),
            _buildMultiSelectChips(_availableHobbies, _hobbies),
            const SizedBox(height: 32),
            _buildSectionTitle('찐친이랑 있을 때 내 성격 🤪'),
            _buildMultiSelectChips(_availableCloseFriendPersonalities, _closeFriendPersonalities),
            const SizedBox(height: 32),
            _buildSectionTitle('내가 중요하게 생각하는 가치관 💎'),
            _buildMultiSelectChips(_availableValues, _values),
            const SizedBox(height: 100),"""
    
    content = re.sub(
        r"_buildSectionTitle\('나의 관심사 / 취향'\),\s*_buildMultiSelectChips\(_availableHobbies, _hobbies\),\s*const SizedBox\(height: 100\),",
        ui_blocks,
        content
    )
    return content

update_file('lib/screens/profile_edit_screen.dart', update_profile_edit)
print("Updated Profile Edit Screen")
