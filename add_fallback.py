import io

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

fallback_ui = '''if (snapshot.hasError) {
                          // Fallback to dummy data
                          final dummyDocs = [
                            {
                              'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
                              'category': '코노/노래',
                              'location': '합정역 수코인노래방',
                              'date': '오늘 저녁 8시',
                              'host': '고음불가',
                              'manner': 38.5,
                              'price': 'N빵',
                              'members': '2/4',
                              'isFemaleOnly': true,
                              'transport': '각자 이동',
                              'imageUrl': 'https://images.unsplash.com/photo-1516280440502-8618eb3090ef?w=800&q=80',
                            },
                            {
                              'title': '주말 엽떡+마라탕 조지실 분',
                              'category': '술/맛집',
                              'location': '홍대입구역 9번 출구',
                              'date': '이번주 토요일 18:00',
                              'host': '매운맛킬러',
                              'manner': 41.2,
                              'price': 'N빵',
                              'members': '2/4',
                              'isFemaleOnly': true,
                              'transport': '각자 이동',
                              'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
                            }
                          ];
                          
                          final filteredDummy = dummyDocs.where((doc) {
                            if (_selectedCategoryIndex == 0) return true;
                            return doc['category'] == _categories[_selectedCategoryIndex]['name'];
                          }).toList();
                          
                          if (filteredDummy.isEmpty) {
                            return const Center(child: Text("선택한 카테고리의 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                          }
                          
                          return ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 4),
                            itemCount: filteredDummy.length,
                            itemBuilder: (context, index) {
                              return _buildMeetupCard(filteredDummy[index]);
                            },
                          );
                        }'''

text = text.replace('if (snapshot.hasError) {\n                          return const Center(child: Text("데이터를 불러오는데 실패했습니다."));\n                        }', fallback_ui)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
