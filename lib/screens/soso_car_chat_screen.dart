import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/interactive_map_popup.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;
  final String chatRoomId; 

  const OOMUChatScreen({
    super.key, 
    required this.title, 
    required this.memberCount,
    this.chatRoomId = 'test_room_01', 
  });

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot>? _firebaseMessageStream;

  final List<Map<String, dynamic>> _dummyMessages = [
    {'type': 'system', 'text': '매운맛킬러(방장)님이 이 모임을 개설했습니다.'},
    {'type': 'system', 'text': '우리동네민우님이 참여 승인되어 합류했습니다! 🎉'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '안녕하세요! 다들 마라탕 좋아하시죠?', 'isMe': false, 'time': '오후 2:30'},
    {'type': 'text', 'sender': '우리동네민우', 'text': '완전완전 좋아합니다ㅎㅎ 잘 부탁드려요!', 'isMe': true, 'time': '오후 2:32'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '그럼 이번주 토요일 6시에 홍대에서 봬요!', 'isMe': false, 'time': '오후 2:35'},
  ];

  @override
  void initState() {
    super.initState();
    try {
      _firebaseMessageStream = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      _firebaseMessageStream = null;
    }
  }

  void _addMessage(Map<String, dynamic> msgData) {
    setState(() {
      _dummyMessages.add({...msgData, 'time': '지금', 'isMe': true, 'sender': '우리동네민우'});
    });
    _scrollToBottom();
    
    try {
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({...msgData, 'isMe': true, 'sender': '우리동네민우', 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('Firebase not connected. Saved to local UI only.');
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _addMessage({'type': 'text', 'text': _controller.text.trim()});
    _controller.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendImageAction() async {
    Navigator.pop(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; 

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진을 업로드하는 중입니다...')));
      
      try {
        final bytes = await image.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref().child('chat_images/${widget.chatRoomId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putData(bytes);
        final downloadUrl = await storageRef.getDownloadURL();
        _addMessage({'type': 'image', 'imageUrl': downloadUrl});
      } catch (e) {
        _addMessage({'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1552674605-15c3704ba158?q=80&w=600'});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진 업로드 실패')));
    }
  }

  Future<void> _sendLocationAction() async {
    Navigator.pop(context);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('현재 위치를 가져오는 중입니다...')));
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final String kakaoMapUrl = 'https://map.kakao.com/link/map/내_현재_위치,${position.latitude},${position.longitude}';
      
      _addMessage({'type': 'location', 'latitude': position.latitude, 'longitude': position.longitude, 'mapUrl': kakaoMapUrl});
    } catch (e) {
      _addMessage({'type': 'location', 'mapUrl': 'https://map.kakao.com/'});
    }
  }

  // ===========================================================================
  // [동적 작동] 일정 생성 폼 (BottomSheet)
  // ===========================================================================
  void _showScheduleCreatorBottomSheet() {
    Navigator.pop(context);
    
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String location = '';
    int maxMembers = 4;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('상세 일정 제안하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Date Picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('날짜 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(selectedDate != null ? '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일' : '터치하여 날짜를 선택하세요'),
                        trailing: const Icon(Icons.edit_calendar, color: Colors.blue),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                      const Divider(),
                      
                      // Time Picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('시간 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(selectedTime != null ? selectedTime!.format(context) : '터치하여 시간을 선택하세요'),
                        trailing: const Icon(Icons.access_time, color: Colors.blue),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                      const Divider(),
                      
                      // Location
                      TextField(
                        onChanged: (val) => location = val,
                        decoration: InputDecoration(
                          labelText: '모임 장소 (예: 스타벅스 여수점)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Members
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('모임 인원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          DropdownButton<int>(
                            value: maxMembers,
                            items: [2,3,4,5,6,7,8].map((e) => DropdownMenuItem(value: e, child: Text('$e명'))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => maxMembers = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            if (selectedDate == null || selectedTime == null || location.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('날짜, 시간, 장소를 모두 입력해주세요.')));
                              return;
                            }
                            Navigator.pop(ctx);
                            _addMessage({
                              'type': 'schedule',
                              'title': '새로운 일정이 제안되었습니다!',
                              'date': '${selectedDate!.month}월 ${selectedDate!.day}일',
                              'timeStr': selectedTime!.format(ctx),
                              'location': location,
                              'maxMembers': maxMembers,
                            });
                          },
                          child: const Text('일정 공유 및 투표 시작', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  // ===========================================================================
  // [동적 작동] 투표 생성 폼 (BottomSheet)
  // ===========================================================================
  void _showPollCreatorBottomSheet() {
    Navigator.pop(context);
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController opt1Ctrl = TextEditingController();
    final TextEditingController opt2Ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [Icon(Icons.how_to_vote, color: Colors.purple), SizedBox(width: 8), Text('투표 만들기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                ),
                const SizedBox(height: 24),
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: '투표 주제', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: opt1Ctrl, decoration: InputDecoration(labelText: '옵션 1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: opt2Ctrl, decoration: InputDecoration(labelText: '옵션 2', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || opt1Ctrl.text.isEmpty || opt2Ctrl.text.isEmpty) {
                         ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
                         return;
                      }
                      Navigator.pop(ctx);
                      _addMessage({'type': 'poll', 'title': '📊 ${titleCtrl.text}', 'opt1': opt1Ctrl.text, 'opt2': opt2Ctrl.text});
                    },
                    child: const Text('투표 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



  // ===========================================================================
  // [동적 작동] 핫플 검색 폼 (BottomSheet)
  // ===========================================================================
  
  void _showSafeReturnBottomSheet() {
    Navigator.pop(context);
    _addMessage({
      'type': 'safe_return',
      'title': '🌃 안전 귀가 알림',
      'desc': '방금 집에 무사히 도착했습니다! 다들 푹 쉬세요~'
    });
  }

  void _showProfileExchangeBottomSheet() {
    Navigator.pop(context);
    _addMessage({
      'type': 'profile_exchange',
      'title': '📇 명함/프로필 교환 요청',
      'desc': '서로의 상세 프로필을 확인해볼까요?'
    });
  }

  void _showHotspotSearchBottomSheet() {
    Navigator.pop(context);
    
    String searchQuery = '';
    String selectedCategory = '전체';
    List<Map<String, dynamic>> searchResults = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {

            Future<void> performSearch(String query) async {
              if (query.trim().isEmpty) return;
              setState(() {
                isLoading = true;
                searchResults = [];
              });

              try {
                // OpenStreetMap Nominatim API (CORS Free, 전국 검색 가능)
                final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&countrycodes=kr');
                final response = await http.get(url, headers: {'User-Agent': 'OOMU_Flutter_Web_App'});
                
                if (response.statusCode == 200) {
                  final List<dynamic> data = json.decode(response.body);
                  setState(() {
                    searchResults = data.map((item) {
                      return {
                        'name': item['name'] ?? item['display_name'].split(',')[0],
                        'category': selectedCategory == '전체' ? '핫플' : selectedCategory,
                        'address': item['display_name'] ?? '주소 정보 없음',
                        'lat': double.tryParse(item['lat'] ?? '37.5665') ?? 37.5665,
                        'lng': double.tryParse(item['lon'] ?? '126.9780') ?? 126.9780,
                      };
                    }).toList();
                  });
                }
              } catch (e) {
                print('Search error: $e');
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.7,
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [Icon(Icons.travel_explore, color: Colors.brown), SizedBox(width: 8), Text('실시간 장소 검색 (전국)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onSubmitted: (val) {
                         searchQuery = val;
                         performSearch(val);
                      },
                      decoration: InputDecoration(
                        hintText: '장소 이름 또는 지역 검색 (예: 여수 카페)',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.brown),
                          onPressed: () => performSearch(searchQuery),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => searchQuery = val,
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['전체', '관광지', '카페', '술집', '빵집'].map((category) {
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if(selected) setState(() => selectedCategory = category);
                              },
                              selectedColor: Colors.brown.withOpacity(0.2),
                              labelStyle: TextStyle(color: isSelected ? Colors.brown : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Expanded(
                      child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                        : searchResults.isEmpty 
                          ? const Center(child: Text('장소 이름이나 지역을 검색해보세요.'))
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final place = searchResults[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  leading: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.place, color: Colors.brown),
                                  ),
                                  title: Text(place['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text('${place['category']} • ${place['address']}', style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _addMessage({
                                        'type': 'hotspot',
                                        'title': '☕ 우리 동네 핫플 추천!',
                                        'name': place['name'],
                                        'category': place['category'],
                                        'address': place['address'],
                                        'lat': place['lat'],
                                        'lng': place['lng'],
                                      });
                                    },
                                    child: const Text('공유', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

    // ===========================================================================
  // [동적 작동] 모임 후기 별점 폼
  // ===========================================================================
  void _showReviewBottomSheet() {
    Navigator.pop(context);
    
    int selectedStars = 5;
    TextEditingController textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [Icon(Icons.rate_review, color: Colors.orange), SizedBox(width: 8), Text('모임 후기 남기기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 8),
                    const Text('이번 모임은 어떠셨나요? 별점과 솔직한 후기를 남겨주세요.\n작성하신 별점은 상대방의 매너 온도에 즉시 반영됩니다.', style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedStars = index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < selectedStars ? Icons.star : Icons.star_border,
                                color: Colors.orange,
                                size: 44,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: textCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '즐거운 모임이었나요? 후기를 자유롭게 적어주세요.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (textCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('후기 내용을 입력해주세요.')));
                            return;
                          }
                          Navigator.pop(ctx);
                          
                          // 글로벌 상태 업데이트 (매너 온도 및 평점 즉시 반영!)
                          globalData.submitReview(selectedStars.toDouble(), textCtrl.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('후기가 프로필에 반영되었습니다!')));
                          
                          _addMessage({
                            'type': 'review',
                            'rating': selectedStars,
                            'text': textCtrl.text,
                          });
                        },
                        child: const Text('후기 공유하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.start,
            children: [
              _buildAttachmentIcon(Icons.image, '사진', Colors.green, onTap: _sendImageAction),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent, onTap: _sendLocationAction),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange, onTap: _showReviewBottomSheet),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue, onTap: _showScheduleCreatorBottomSheet),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple, onTap: _showPollCreatorBottomSheet),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)), 
              _buildAttachmentIcon(Icons.local_cafe, '핫플 공유', Colors.brown, onTap: _showHotspotSearchBottomSheet),
              _buildAttachmentIcon(Icons.directions_car, '동행/드라이브', Colors.indigo, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'carpool', 'title': '🚗 오늘 저녁 드라이브 가실 분?', 'desc': '목적지: 북악스카이웨이'});
              }),
              _buildAttachmentIcon(Icons.contact_emergency, '안전귀가', Colors.pink, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'safe_return', 'title': '🏠 안전 귀가 알림', 'desc': '방금 집에 무사히 도착했습니다! 다들 푹 쉬세요.'});
              }),
              _buildAttachmentIcon(Icons.badge, '프로필 교환', Colors.teal, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'profile_exchange', 'title': '🤝 명함/프로필 교환 요청', 'desc': '서로의 상세 프로필을 확인해볼까요?'});
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label 기능이 준비중입니다.')));
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.memberCount}명 참여중', style: TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu, color: textPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildAppointmentCard(),
          Expanded(
            child: _firebaseMessageStream == null
                ? _buildDummyMessageList() 
                : StreamBuilder<QuerySnapshot>(
                    stream: _firebaseMessageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildDummyMessageList(); 
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildDynamicMessage(data);
                        },
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDummyMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _dummyMessages.length,
      itemBuilder: (context, index) {
        final msg = _dummyMessages[index];
        return _buildDynamicMessage(msg);
      },
    );
  }

  Widget _buildDynamicMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    if (type == 'system') return _buildSystemMessage(data['text'] ?? '');
    if (type == 'settlement') return _buildSettlementMessage(data);
    if (type == 'image') return _buildImageMessage(data);
    if (type == 'location') return _buildLocationMessage(data);
    
    if (type == 'schedule') return InteractiveScheduleCard(msg: data, isMe: data['isMe'] == true);
    if (type == 'poll') return InteractivePollCard(msg: data, isMe: data['isMe'] == true);
    
    if (type == 'hotspot') return InteractiveHotspotCard(msg: data, isMe: data['isMe'] == true);
    if (type == 'review') return InteractiveReviewCard(msg: data, isMe: data['isMe'] == true);
    
    if (type == 'safe_return') return InteractiveSafeReturnCard(msg: data, isMe: data['isMe'] == true);
    if (type == 'profile_exchange') return InteractiveProfileExchangeCard(msg: data, isMe: data['isMe'] == true);
    if (['carpool'].contains(type)) {

      return _buildInteractiveCardMessage(data);
    }
    return _buildTextMessage(data);
  }

  Widget _buildInteractiveCardMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    IconData icon = Icons.info;
    Color iconColor = accentColor;

    switch(msg['type']) {
      case 'review': icon = Icons.rate_review; iconColor = Colors.orange; break;
      case 'hotspot': icon = Icons.local_cafe; iconColor = Colors.brown; break;
      case 'carpool': icon = Icons.directions_car; iconColor = Colors.indigo; break;
      case 'safe_return': icon = Icons.contact_emergency; iconColor = Colors.pink; break;
      case 'profile_exchange': icon = Icons.badge; iconColor = Colors.teal; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: iconColor.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(msg['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(msg['desc'] ?? '', style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${msg['title']}에 반응했습니다!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: iconColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('반응하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final imageUrl = msg['imageUrl'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final mapUrl = msg['mapUrl'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              if (mapUrl.isNotEmpty) {
                final Uri url = Uri.parse(mapUrl);
                if (!await launchUrl(url)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
              }
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: accentColor, size: 20),
                      const SizedBox(width: 4),
                      const Text('현재 위치 공유', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100, width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'), fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: const Text('카카오맵 열기', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text('약속 확정!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFEFE5), borderRadius: BorderRadius.circular(12)),
                child: Text('D-2', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('일시: 2026. 9. 26 (토) 오후 6:00', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('장소: 홍대입구역 9번 출구 앞', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const InteractiveMapPopup(
                  initialCenter: LatLng(37.5568, 126.9242),
                  locationName: '홍대입구역 9번 출구',
                  kakaoLink: 'https://map.kakao.com/link/map/홍대입구역 9번출구,37.5568,126.9242',
                ),
              );
            },
            child: Container(
              height: 80, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.3)),
                child: const Center(child: Text('📍 지도에서 위치 보기 (클릭)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(text, style: TextStyle(fontSize: 12, color: textPrimary.withOpacity(0.8))),
        ),
      ),
    );
  }

  Widget _buildSettlementMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.3)),
              boxShadow: [BoxShadow(color: const Color(0xFFF19E39).withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFFFEFE5), shape: BoxShape.circle), child: const Icon(Icons.payments, color: Color(0xFFF19E39), size: 16)),
                    const SizedBox(width: 8),
                    const Text('1/N 정산 요청', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(msg['title'] ?? '', style: TextStyle(fontSize: 13, color: textSecondary)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('총 지출', style: TextStyle(fontSize: 14)), Text('${msg['total']}원', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('내가 보낼 금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('${msg['perPerson']}원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF19E39))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF19E39), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('보내기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? accentColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(msg['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : textPrimary, fontSize: 15, height: 1.4)),
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'));
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: _showAttachmentMenu,
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle), child: Icon(Icons.add, color: textSecondary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: '메시지 보내기', hintStyle: TextStyle(color: textSecondary, fontSize: 15), border: InputBorder.none),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 일정 참석 투표 카드
// ===========================================================================
class InteractiveScheduleCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveScheduleCard({super.key, required this.msg, required this.isMe});

  @override
  State<InteractiveScheduleCard> createState() => _InteractiveScheduleCardState();
}

class _InteractiveScheduleCardState extends State<InteractiveScheduleCard> {
  bool _isAttending = false;
  int _attendCount = 1; // 기본적으로 제안자는 참석

  @override
  Widget build(BuildContext context) {
    int maxMembers = widget.msg['maxMembers'] ?? 4;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.calendar_month, color: Colors.blue, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.msg['title'] ?? '일정 제안', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(children: [const Text('📅 날짜: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text(widget.msg['date'] ?? '-', style: const TextStyle(fontSize: 12))]),
                      const SizedBox(height: 4),
                      Row(children: [const Text('⏰ 시간: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text(widget.msg['timeStr'] ?? widget.msg['time'] ?? '-', style: const TextStyle(fontSize: 12))]),
                      const SizedBox(height: 4),
                      Row(children: [const Text('📍 장소: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text(widget.msg['location'] ?? '-', style: const TextStyle(fontSize: 12))]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🙋 참석 인원 현황', style: TextStyle(fontSize: 12, color: Color(0xFF767676))),
                    Text('$_attendCount / $maxMembers 명', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                LinearProgressIndicator(
                  value: _attendCount / maxMembers,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isAttending && _attendCount >= maxMembers) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모집 인원이 마감되었습니다!')));
                        return;
                      }
                      setState(() {
                        _isAttending = !_isAttending;
                        _isAttending ? _attendCount++ : _attendCount--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAttending ? Colors.grey[300] : Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isAttending ? '참석 취소하기' : '👍 저도 참석할게요!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: _isAttending ? Colors.black87 : Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}



// ===========================================================================
// 동적 컴포넌트: 안건 투표 카드
// ===========================================================================
class InteractivePollCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractivePollCard({super.key, required this.msg, required this.isMe});

  @override
  State<InteractivePollCard> createState() => _InteractivePollCardState();
}

class _InteractivePollCardState extends State<InteractivePollCard> {
  int? _selectedOption;
  int _opt1Count = 0;
  int _opt2Count = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          
          Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.how_to_vote, color: Colors.purple, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.msg['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPollOption(1, widget.msg['opt1'] ?? '옵션 1', _opt1Count),
                const SizedBox(height: 8),
                _buildPollOption(2, widget.msg['opt2'] ?? '옵션 2', _opt2Count),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }

  Widget _buildPollOption(int optionIndex, String text, int count) {
    bool isSelected = _selectedOption == optionIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedOption == optionIndex) {
            _selectedOption = null;
            if (optionIndex == 1) _opt1Count--; else _opt2Count--;
          } else {
            if (_selectedOption == 1) _opt1Count--;
            if (_selectedOption == 2) _opt2Count--;
            _selectedOption = optionIndex;
            if (optionIndex == 1) _opt1Count++; else _opt2Count++;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.1) : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.purple : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(text, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.purple : Colors.black87))),
            Text('$count명', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.purple : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 핫플 공유 카드
// ===========================================================================
class InteractiveHotspotCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveHotspotCard({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String name = msg['name'] ?? '핫플 이름';
    final String address = msg['address'] ?? '주소 정보 없음';
    final double lat = msg['lat'] ?? 37.5665;
    final double lng = msg['lng'] ?? 126.9780;
    
    // 실제 카카오맵 링크 생성 (이름과 좌표 포함)
    final String kakaoMapUrl = 'https://map.kakao.com/link/map/$name,$lat,$lng';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: const Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.local_cafe, color: Colors.brown, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(msg['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(fontSize: 12, color: const Color(0xFF767676))),
                const SizedBox(height: 12),
                
                // 미니 지도 썸네일
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(kakaoMapUrl);
                    if (!await launchUrl(url)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
                  },
                  child: Container(
                    height: 90, width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'), fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: const Text('카카오맵 열기', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: const Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 리뷰 공유 카드
// ===========================================================================
class InteractiveReviewCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveReviewCard({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.rate_review, color: Colors.orange, size: 16)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('✨ 모임 후기가 도착했어요!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                  child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}


// ===========================================================================
// 동적 컴포넌트: 안전 귀가 (Safe Return)
// ===========================================================================
class InteractiveSafeReturnCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const InteractiveSafeReturnCard({super.key, required this.msg, required this.isMe});
  @override
  State<InteractiveSafeReturnCard> createState() => _InteractiveSafeReturnCardState();
}
class _InteractiveSafeReturnCardState extends State<InteractiveSafeReturnCard> {
  int _likes = 0;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.pink.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.nightlight_round, color: Colors.pink, size: 20),
                    const SizedBox(width: 8),
                    Text(widget.msg['title'] ?? '안전 귀가', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.pink)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.msg['desc'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      _isLiked ? _likes++ : _likes--;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isLiked ? Colors.pink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: _isLiked ? Colors.white : Colors.pink, size: 16),
                        const SizedBox(width: 6),
                        Text('다행이에요! $_likes', style: TextStyle(color: _isLiked ? Colors.white : Colors.pink, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 프로필 교환 (Profile Exchange)
// ===========================================================================
class InteractiveProfileExchangeCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const InteractiveProfileExchangeCard({super.key, required this.msg, required this.isMe});
  @override
  State<InteractiveProfileExchangeCard> createState() => _InteractiveProfileExchangeCardState();
}
class _InteractiveProfileExchangeCardState extends State<InteractiveProfileExchangeCard> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.badge, color: Colors.teal, size: 28)),
                const SizedBox(height: 12),
                Text(widget.msg['title'] ?? '명함 교환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                const SizedBox(height: 8),
                Text(widget.msg['desc'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 16),
                if (!widget.isMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _accepted ? null : () {
                        setState(() => _accepted = true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 교환을 수락했습니다! 이제 상대방의 상세 프로필을 볼 수 있습니다.')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_accepted ? '교환 완료 🤝' : '수락하기', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (widget.isMe)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('상대방의 수락을 대기중입니다...', style: TextStyle(fontSize: 12, color: Colors.teal))),
                  )
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}
