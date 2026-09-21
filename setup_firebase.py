import os
import io

# 1. Update pubspec.yaml
with io.open('pubspec.yaml', 'r', encoding='utf-8') as f:
    pubspec = f.read()

if 'firebase_core' not in pubspec:
    pubspec = pubspec.replace('cupertino_icons: ^1.0.8', 'cupertino_icons: ^1.0.8\n  firebase_core: ^3.6.0\n  cloud_firestore: ^5.4.3')
    with io.open('pubspec.yaml', 'w', encoding='utf-8') as f:
        f.write(pubspec)

# 2. Update main.dart
with io.open('lib/main.dart', 'r', encoding='utf-8') as f:
    main_dart = f.read()

if 'firebase_core.dart' not in main_dart:
    imports = "import 'package:flutter/material.dart';\nimport 'package:firebase_core/firebase_core.dart';\n"
    main_dart = main_dart.replace("import 'package:flutter/material.dart';", imports)
    
    init_code = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U",
        authDomain: "test-b54fc.firebaseapp.com",
        projectId: "test-b54fc",
        storageBucket: "test-b54fc.firebasestorage.app",
        messagingSenderId: "610801542567",
        appId: "1:610801542567:web:6eb035b321d9ac7b688282",
        measurementId: "G-341F6S06TG",
      ),
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const MyApp());
}"""
    # Replace void main() { runApp(const MyApp()); }
    import re
    main_dart = re.sub(r'void main\(\)\s*{\s*runApp\(const MyApp\(\)\);\s*}', init_code, main_dart)
    with io.open('lib/main.dart', 'w', encoding='utf-8') as f:
        f.write(main_dart)

# 3. Update soso_car_home_screen.dart
with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    home_dart = f.read()

if 'cloud_firestore' not in home_dart:
    home_dart = home_dart.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';")
    
    # Remove the dummy _meetups list and replace with a seeder and StreamBuilder
    
    # First, let's extract the list and create the seeder
    seeder_func = """
  @override
  void initState() {
    super.initState();
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('meetups').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final dummyMeetups = [
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
            'createdAt': FieldValue.serverTimestamp()
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
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '파주 대형 북카페로 드라이브 가요',
            'category': '여행/드라이브',
            'location': '파주 지혜의 숲',
            'date': '일요일 14:00',
            'host': '달리는 민우',
            'manner': 42.8,
            'price': 'N빵',
            'members': '1/3',
            'isFemaleOnly': false,
            'transport': '호스트 차로 같이 이동',
            'imageUrl': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&q=80',
            'createdAt': FieldValue.serverTimestamp()
          }
        ];
        for (var m in dummyMeetups) {
          await FirebaseFirestore.instance.collection('meetups').add(m);
        }
      }
    } catch (e) {
      debugPrint("Seed error: $e");
    }
  }
"""
    # Insert seeder after the _categories definition
    home_dart = re.sub(r"\];\s*@override\s*Widget build\(BuildContext context\) {", "];\n" + seeder_func + "\n  @override\n  Widget build(BuildContext context) {", home_dart)
    
    # Remove the old _meetups variable
    # It starts with: final List<Map<String, dynamic>> _meetups = [ ... ];
    home_dart = re.sub(r"final List<Map<String, dynamic>> _meetups = \[.*?\];\s*", "", home_dart, flags=re.DOTALL)
    
    # Replace ListView.builder with StreamBuilder
    listview_str = """Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 4),
                      itemCount: _meetups.length,
                      itemBuilder: (context, index) {
                        if (_selectedCategoryIndex != 0 && _meetups[index]['category'] != _categories[_selectedCategoryIndex]['name']) {
                          return const SizedBox.shrink();
                        }
                        return _buildMeetupCard(_meetups[index]);
                      },
                    ),
                  )"""
                  
    stream_builder_str = """Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.black));
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text("데이터를 불러오는데 실패했습니다."));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("아직 등록된 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                        }
                        
                        final docs = snapshot.data!.docs;
                        final filteredDocs = docs.where((doc) {
                          if (_selectedCategoryIndex == 0) return true;
                          var data = doc.data() as Map<String, dynamic>;
                          return data['category'] == _categories[_selectedCategoryIndex]['name'];
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(child: Text("선택한 카테고리의 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 4),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            var data = filteredDocs[index].data() as Map<String, dynamic>;
                            return _buildMeetupCard(data);
                          },
                        );
                      },
                    ),
                  )"""
                  
    home_dart = home_dart.replace(listview_str, stream_builder_str)
    
    with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(home_dart)

# 4. Modify soso_car_host_screen.dart to actually write to Firestore
with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    host_dart = f.read()

if 'cloud_firestore' not in host_dart:
    host_dart = host_dart.replace("import 'package:flutter/cupertino.dart';", "import 'package:flutter/cupertino.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';")
    
    # Add controllers to capture input
    controllers_code = """
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
"""
    host_dart = host_dart.replace("String _selectedCategory = '';", "String _selectedCategory = '';\n" + controllers_code)
    
    # Update TextFields to use controllers
    host_dart = host_dart.replace("_buildTextField('모임 제목', '예: 불금엔 역시 코노! 스트레스 풀 분')", "_buildTextField('모임 제목', '예: 불금엔 역시 코노! 스트레스 풀 분', _titleController)")
    host_dart = host_dart.replace("_buildTextField('만날 장소', '예: 홍대입구역 9번 출구 앞')", "_buildTextField('만날 장소', '예: 홍대입구역 9번 출구 앞', _locationController)")
    host_dart = host_dart.replace("_buildTextField('일시', '예: 이번주 토요일 오후 2시')", "_buildTextField('일시', '예: 이번주 토요일 오후 2시', _dateController)")
    
    textfield_method = """  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFAEAEC2), fontSize: 15),
            filled: true,
            fillColor: surfaceColor,"""
    
    old_textfield_method = """  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFAEAEC2), fontSize: 15),
            filled: true,
            fillColor: surfaceColor,"""
    
    host_dart = host_dart.replace(old_textfield_method, textfield_method)
    
    # Handle submit logic
    submit_button_old = """ElevatedButton(
              onPressed: () {"""
    
    submit_button_new = """ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _selectedCategory.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카테고리와 제목을 입력해주세요!')));
                   return;
                }
                
                // Firestore에 데이터 쓰기!
                await FirebaseFirestore.instance.collection('meetups').add({
                  'title': _titleController.text,
                  'category': _selectedCategory,
                  'location': _locationController.text.isEmpty ? '위치 미정' : _locationController.text,
                  'date': _dateController.text.isEmpty ? '시간 미정' : _dateController.text,
                  'host': '매운맛킬러', // Dummy User
                  'manner': 41.2,
                  'price': 'N빵',
                  'members': '1/4',
                  'isFemaleOnly': _isFemaleOnly,
                  'transport': _transportMethod,
                  'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80', // Dummy Image
                  'createdAt': FieldValue.serverTimestamp()
                });
"""
    host_dart = host_dart.replace(submit_button_old, submit_button_new)
    
    with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
        f.write(host_dart)
