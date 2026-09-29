import io
import re

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

dummy_method = """
  Widget _buildDummyMeetups() {
    final List<Map<String, dynamic>> dummyData = [
      {
        'title': '성수동 카페 투어 하실 분!',
        'location': '성동구 성수동',
        'date': '오늘 오후 3:00',
        'imageUrl': 'https://images.unsplash.com/photo-1501339817309-1141e1ee256e?q=80&w=600&auto=format&fit=crop',
        'tags': ['소소하게', '커피', '당일치기'],
      },
      {
        'title': '한강 러닝 메이트 구해요 🏃‍♂️',
        'location': '마포구 망원동',
        'date': '내일 오전 7:00',
        'imageUrl': 'https://images.unsplash.com/photo-1552674605-15c3704ba158?q=80&w=600&auto=format&fit=crop',
        'tags': ['러닝', '운동', '건강'],
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return _buildMeetupCard(dummyData[index]);
      },
    );
  }

  Stream<QuerySnapshot>? _getMeetupStream() {
    try {
      return FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).limit(20).snapshots();
    } catch (e) {
      return null;
    }
  }
"""

if "_buildDummyMeetups()" not in content:
    content = content.replace("class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {", "class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {" + dummy_method)

# Manually find and replace the block
start_idx = content.find("// 4. StreamBuilder (List of Meetups)")
end_idx = content.find("const SliverToBoxAdapter(child: SizedBox(height: 40)),")

new_stream = """          // 4. StreamBuilder (List of Meetups) - with Fallback
          SliverToBoxAdapter(
            child: _getMeetupStream() == null
              ? _buildDummyMeetups()
              : StreamBuilder<QuerySnapshot>(
                  stream: _getMeetupStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildDummyMeetups(); // 데이터가 없거나 에러나면 더미 보여주기
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return _buildMeetupCard(data);
                      },
                    );
                  },
                ),
          ),
          
          """

content = content[:start_idx] + new_stream + content[end_idx:]

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
