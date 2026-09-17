import io

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Fix 1: The print statement error caused by powershell escaping
code = code.replace('print("Kpostal error: \\\\");', 'print("Kpostal error: \");')
# Just in case:
code = code.replace('print("Kpostal error: \\");', 'print("Kpostal error: \");')
code = code.replace('print("Kpostal error: \\");', 'print("Kpostal error: \");')

# Fix 2: Remove const before Expanded in _buildCarSection
code = code.replace('const Expanded(\n                  child: Column(', 'Expanded(\n                  child: Column(')

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)