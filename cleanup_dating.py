import io
import os

files_to_delete = [
    'lib/screens/profile_detail_screen.dart',
    'lib/screens/balance_game_lobby_screen.dart',
    'lib/screens/fake_call_screen.dart',
    'lib/screens/meet_proposal_screen.dart',
    'lib/screens/mission_clue_screen.dart',
    'lib/screens/signal_group_chat_screen.dart',
    'lib/screens/signal_house_intro_screen.dart',
    'lib/screens/signal_house_list_screen.dart',
    'lib/screens/secret_memo_screen.dart',
    'lib/screens/voice_ping_screen.dart'
]

for f in files_to_delete:
    if os.path.exists(f):
        os.remove(f)
        print(f"Deleted {f}")

with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    for line in lines:
        if 'SignalHouseIntroScreen' in line:
            continue
        f.write(line)

print("Cleaned up home_screen.dart")
