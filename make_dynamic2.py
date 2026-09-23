import io

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    home = f.read()

home = home.replace(
    'onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen())),',
    'onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),'
)
# Make sure to import soso_car_detail_screen.dart if not already
if 'soso_car_detail_screen.dart' not in home:
    home = home.replace("import 'chat_screen.dart';", "import 'chat_screen.dart';\nimport 'soso_car_detail_screen.dart';")

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(home)

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    detail = f.read()

if 'final Map<String, dynamic>? meetup;' not in detail:
    detail = detail.replace('class OOMUDetailScreen extends StatelessWidget {', 'class OOMUDetailScreen extends StatelessWidget {\n  final Map<String, dynamic>? meetup;')
    detail = detail.replace('const OOMUDetailScreen({super.key});', 'const OOMUDetailScreen({super.key, this.meetup});')

    def r(o, k):
        global detail
        detail = detail.replace(f"'{o}'", f"(meetup != null ? meetup!['{k}'] : '{o}')")
    
    r('주말 엽떡+마라탕 조지실 분', 'title')
    r('홍대입구역 9번 출구', 'location')
    r('이번주 토요일 18:00', 'date')
    r('술/맛집', 'category')
    r('매운맛킬러', 'host')
    r('N빵', 'price')
    r('각자 이동', 'transport')
    r('2/4', 'members')
    
    detail = detail.replace("NetworkImage('https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80')", "NetworkImage(meetup != null ? meetup!['imageUrl'] : 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80')")
    
    detail = detail.replace(
        "Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '주말 엽떡+마라탕 조지실 분', memberCount: 3)));",
        "Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: meetup != null ? meetup!['title'] : '주말 엽떡+마라탕 조지실 분', memberCount: 3)));"
    )

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(detail)

