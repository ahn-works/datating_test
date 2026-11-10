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
    r'lib/screens/oomu_home_screen.dart',
    r'lib/screens/oomu_detail_screen.dart',
    r'lib/screens/oomu_host_screen.dart',
    r'lib/screens/oomu_chat_room_screen.dart',
    r'lib/screens/community_post_create_screen.dart',
    r'lib/screens/notification_screen.dart',
    r'lib/screens/saved_meetups_screen.dart',
    r'lib/screens/local_friends_screen.dart',
    r'lib/screens/my_page_screen.dart',
    r'lib/screens/user_profile_screen.dart',
    r'lib/screens/community_post_detail_screen.dart',
    r'lib/screens/chat_screen.dart',
    r'lib/widgets/bouncy_tap.dart',
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

        if not in_single_str and not in_double_str:
            if c == '/' and i + 1 < n:
                if content[i+1] == '/':
                    while i < n and content[i] != '\n':
                        i += 1
                    continue
                elif content[i+1] == '*':
                    i += 2
                    while i + 1 < n and not (content[i] == '*' and content[i+1] == '/'):
                        if content[i] == '\n':
                            line += 1
                            col = 1
                        i += 1
                    i += 2
                    continue

        if c == '\\' and (in_single_str or in_double_str):
            escaped = not escaped
            i += 1
            col += 1
            continue

        if c == "'" and not in_double_str and not escaped:
            in_single_str = not in_single_str
        elif c == '"' and not in_single_str and not escaped:
            in_double_str = not in_double_str
        elif not in_single_str and not in_double_str:
            if c in pairs.keys():
                stack.append((c, line, col))
            elif c in pairs.values():
                if not stack:
                    print(f"[SYNTAX ERROR] Unmatched closing bracket '{c}' at {filepath}:{line}:{col}")
                    return False
                top, t_line, t_col = stack.pop()
                if pairs[top] != c:
                    print(f"[SYNTAX ERROR] Mismatched bracket: opened '{top}' at {t_line}:{t_col}, but closed with '{c}' at {filepath}:{line}:{col}")
                    return False

        escaped = False
        i += 1
        col += 1

    if in_single_str or in_double_str:
        print(f"[SYNTAX ERROR] Unterminated string literal in {filepath}")
        return False

    if stack:
        top, t_line, t_col = stack[-1]
        print(f"[SYNTAX ERROR] Unclosed bracket '{top}' opened at {filepath}:{t_line}:{t_col}")
        return False

    print(f"[PASS] {filepath} - Clean balance, zero syntax/bracket errors.")
    return True

if __name__ == '__main__':
    all_pass = True
    for f in files:
        if not verify_file(f):
            all_pass = False

    if all_pass:
        print(f"\n[ALL {len(files)} FILES VERIFIED] Every modified Dart file passed syntax and bracket verification!")
        sys.exit(0)
    else:
        print("\n[VERIFICATION FAILED] Please inspect the syntax errors above.")
        sys.exit(1)
