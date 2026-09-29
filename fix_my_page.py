import io

with io.open('lib/screens/my_page_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    if "const Text('시크릿 프로필 열람" in line or "const Text('?크??로???람" in line:
        if i + 1 < len(lines):
            # merge the next line
            next_line = lines[i+1].strip()
            line = line.replace("\n", " " + next_line + "\n")
            i += 1
    new_lines.append(line)
    i += 1

with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.writelines(new_lines)
