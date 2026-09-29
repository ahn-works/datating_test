import io

with io.open('lib/widgets/interactive_map_popup.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("center: initialCenter", "initialCenter: initialCenter")
content = content.replace("zoom: 16.0", "initialZoom: 16.0")
content = content.replace("interactiveFlags: InteractiveFlag.all,", "")
content = content.replace("builder: (ctx) => const Icon", "child: const Icon")

with io.open('lib/widgets/interactive_map_popup.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
