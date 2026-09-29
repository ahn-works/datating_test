import io

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_content = """import 'package:flutter/material.dart';
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
    // 1. Local Fallback Update
    setState(() {
      _dummyMessages.add({...msgData, 'time': '지금', 'isMe': true, 'sender': '우리동네민우'});
    });
    _scrollToBottom();
    
    // 2. Firebase Update
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
    Navigator.pop(context); // Close bottom sheet
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; 

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진을 업로드하는 중입니다...')));
      
      // Try Firebase
      try {
        final bytes = await image.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref().child('chat_images/${widget.chatRoomId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putData(bytes);
        final downloadUrl = await storageRef.getDownloadURL();
        _addMessage({'type': 'image', 'imageUrl': downloadUrl});
      } catch (e) {
        // Fallback for Web Demo
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
      // Fallback 
      _addMessage({'type': 'location', 'mapUrl': 'https://map.kakao.com/'});
    }
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
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'review', 'title': '✨ 모임 후기 작성하기', 'desc': '즐거운 모임이었나요? 후기를 남겨주세요.'});
              }),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'schedule', 'title': '📅 일정 제안', 'desc': '다음 모임 날짜를 투표해 볼까요?'});
              }),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'poll', 'title': '📊 투표: 뭐 먹을까요?', 'desc': '마라탕 vs 삼겹살 vs 치킨'});
              }),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)), // 더치페이는 기존 유지
              _buildAttachmentIcon(Icons.local_cafe, '핫플 공유', Colors.brown, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'hotspot', 'title': '☕ 분위기 좋은 성수 카페 추천!', 'desc': '나만 아는 조용한 핫플 공유합니다.'});
              }),
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
    if (['review', 'schedule', 'poll', 'hotspot', 'carpool', 'safe_return', 'profile_exchange'].contains(type)) {
      return _buildInteractiveCardMessage(data);
    }
    return _buildTextMessage(data);
  }

  // [Interactive Card Renderer for all new dynamic features]
  Widget _buildInteractiveCardMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    IconData icon = Icons.info;
    Color iconColor = accentColor;

    switch(msg['type']) {
      case 'review': icon = Icons.rate_review; iconColor = Colors.orange; break;
      case 'schedule': icon = Icons.calendar_month; iconColor = Colors.blue; break;
      case 'poll': icon = Icons.how_to_vote; iconColor = Colors.purple; break;
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: iconColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('참여하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
"""

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(new_content)
