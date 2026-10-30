import sys
from pathlib import Path

files = [
    r'lib/screens/party_detail_screen.dart',
    r'lib/screens/party_screen.dart',
    r'lib/screens/party_host_screen.dart',
    r'lib/screens/party_application_screen.dart',
    r'lib/screens/travel_payment_screen.dart',
    r'lib/screens/profile_edit_screen.dart',
    r'lib/screens/empty_state_screen.dart',
    r'lib/screens/error_screen.dart',
    r'lib/screens/home_screen.dart',
    r'lib/screens/community_post_create_screen.dart',
    r'lib/screens/notification_screen.dart',
    r'lib/screens/saved_meetups_screen.dart',
    r'lib/screens/local_friends_screen.dart',
    r'lib/screens/soso_car_detail_screen.dart',
    r'lib/screens/soso_car_home_screen.dart',
    r'lib/screens/my_page_screen.dart',
    r'lib/screens/user_profile_screen.dart',
    r'lib/screens/community_post_detail_screen.dart',
    r'lib/screens/chat_screen.dart',
    r'lib/widgets/bouncy_tap.dart',
    r'lib/widgets/oomu_spring_sheet.dart',
]

def verify_file(filepath):
    p = Path(filepath)
    if not p.exists():
        print(f"[MISSING] {filepath} does not exist!")
        return False
        
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()

    stack = []
    pairs = {'(': ')', '{': '}', '[': ']'}
    in_single_str = False
    in_double_str = False
    escaped = False

    i = 0
    line = 1
    col = 1
    n = len(content)

    while i < n:
        c = content[i]
        if c == '\n':
            line += 1
            col = 1
            i += 1
            escaped = False
            continue

        # Handle comments when not in string
        if not in_single_str and not in_double_str:
            if c == '/' and i + 1 < n and content[i + 1] == '/':
                # single line comment
                while i < n and content[i] != '\n':
                    i += 1
                continue
            if c == '/' and i + 1 < n and content[i + 1] == '*':
                # multi-line comment
                i += 2
                while i + 1 < n and not (content[i] == '*' and content[i + 1] == '/'):
                    if content[i] == '\n':
                        line += 1
                    i += 1
                i += 2
                continue

        # Handle string literals
        if not in_single_str and not in_double_str:
            if c == "'":
                in_single_str = True
                escaped = False
            elif c == '"':
                in_double_str = True
                escaped = False
            elif c in pairs:
                stack.append((c, line, col))
            elif c in pairs.values():
                if not stack:
                    print(f"[ERROR] {filepath}:{line}:{col} - Unexpected closing bracket '{c}'")
                    return False
                top, tline, tcol = stack.pop()
                if pairs[top] != c:
                    print(f"[ERROR] {filepath}:{line}:{col} - Mismatched '{c}', expected '{pairs[top]}' for '{top}' from line {tline}")
                    return False
        elif in_single_str:
            if c == '\\' and not escaped:
                escaped = True
            elif c == "'" and not escaped:
                in_single_str = False
            else:
                escaped = False
        elif in_double_str:
            if c == '\\' and not escaped:
                escaped = True
            elif c == '"' and not escaped:
                in_double_str = False
            else:
                escaped = False

        col += 1
        i += 1

    if stack:
        print(f"[ERROR] {filepath} - Unclosed brackets left: {stack}")
        return False

    print(f"[PASS] {filepath} - Clean balance, zero syntax/bracket errors.")
    return True

all_passed = True
for f in files:
    if not verify_file(f):
        all_passed = False

if all_passed:
    print(f"\n[ALL {len(files)} FILES VERIFIED] Every modified Dart file passed syntax and bracket verification!")
    sys.exit(0)
else:
    print("\n[VERIFICATION FAILED] Please inspect the syntax errors above.")
    sys.exit(1)
