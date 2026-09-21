import os

def check_imports():
    dart_files = []
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if f.endswith('.dart'):
                dart_files.append(os.path.join(root, f))
                
    deleted_files = [
        'balance_game_lobby_screen.dart',
        'fake_call_screen.dart',
        'meet_proposal_screen.dart',
        'mission_clue_screen.dart',
        'signal_group_chat_screen.dart',
        'signal_house_intro_screen.dart',
        'signal_house_list_screen.dart',
        'secret_memo_screen.dart',
        'voice_ping_screen.dart',
        'profile_detail_screen.dart',
        'chat_room_screen.dart'
    ]

    for df in dart_files:
        with open(df, 'r', encoding='utf-8') as f:
            content = f.read()
            for deleted in deleted_files:
                if f"import '{deleted}'" in content or f'import "{deleted}"' in content:
                    print(f"Error: {df} imports deleted file {deleted}")

check_imports()
