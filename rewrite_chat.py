import io

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    original = f.read()

new_content = """import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/interactive_map_popup.dart';

// [Firebase 및 동적 패키지 임포트]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

// ============================================================================
// [상태 관리 및 비즈니스 로직 분리: ChatService (Riverpod/Provider/GetX 컨트롤러 역할)]
// UI와 데이터 비즈니스 로직을 분리하여 상태 관리를 용이하게 합니다.
// ============================================================================
class ChatService {
  final String chatRoomId;
  ChatService(this.chatRoomId);

  // 1. 메시지 스트림 (실시간 렌더링)
  Stream<QuerySnapshot>? getMessageStream() {
    try {
      return FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      debugPrint('Firebase 미초기화 상태 (더미 모드 작동)');
      return null; // Firebase 세팅 전 앱 크래시 방지
    }
  }

  // 2. 사진 전송 로직 (image_picker + firebase_storage + cloud_firestore)
  Future<void> sendImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) {
        // 사용자가 사진 선택을 취소했을 때의 예외 처리
        return; 
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진을 업로드하는 중입니다...')));

      // Firebase Storage 업로드 (웹 호환을 위해 bytes 사용)
      final bytes = await image.readAsBytes();
      final storageRef = FirebaseStorage.instance.ref().child('chat_images/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putData(bytes);
      
      // 다운로드 URL 획득
      final downloadUrl = await storageRef.getDownloadURL();

      // Firestore 저장
      await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').add({
        'type': 'image',
        'sender': '우리동네민우',
        'isMe': true,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 업로드 실패: $e')));
    }
  }

  // 3. 위치 전송 로직 (geolocator + cloud_firestore)
  Future<void> sendLocation(BuildContext context) async {
    try {
      // 위치 권한 요청 로직 포함
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('현재 위치를 가져오는 중입니다...')));
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 카카오맵 URL 생성
      final String kakaoMapUrl = 'https://map.kakao.com/link/map/내_현재_위치,${position.latitude},${position.longitude}';

      // Firestore 저장
      await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').add({
        'type': 'location',
        'sender': '우리동네민우',
        'isMe': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'mapUrl': kakaoMapUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('위치 공유 실패: $e')));
    }
  }

  // 일반 텍스트 메시지 전송
  Future<void> sendTextMessage(String text) async {
    try {
      await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').add({
        'type': 'text',
        'sender': '우리동네민우',
        'text': text,
        'isMe': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('메시지 전송 실패 (더미 렌더링 의존)');
    }
  }
}
// ============================================================================


class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;
  final String chatRoomId; // 실시간 DB 연동을 위한 식별자 추가

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

  late final ChatService _chatService;
  Stream<QuerySnapshot>? _firebaseMessageStream;

  // [더미 데이터 보존 (Firebase 환경 미구성 시 폴백 용도)]
  final List<Map<String, dynamic>> _dummyMessages = [
    {'type': 'system', 'text': '매운맛킬러(방장)님이 이 모임을 개설했습니다.'},
    {'type': 'system', 'text': '우리동네민우님이 참여 승인되어 합류했습니다! 🎉'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '안녕하세요! 다들 마라탕 좋아하시죠?', 'isMe': false, 'time': '오후 2:30'},
    {'type': 'text', 'sender': '우리동네민우', 'text': '완전완전 좋아합니다ㅎㅎ 잘 부탁드려요!', 'isMe': true, 'time': '오후 2:32'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '그럼 이번주 토요일 6시에 홍대에서 봬요!', 'isMe': false, 'time': '오후 2:35'},
    {'type': 'settlement', 'sender': '매운맛킬러', 'total': 45000, 'perPerson': 15000, 'title': '마라탕 & 카페 N빵', 'isMe': false, 'time': '오후 8:00'},
  ];

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(widget.chatRoomId);
    _firebaseMessageStream = _chatService.getMessageStream();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    // 1. Firebase 실제 전송 (연동 시)
    _chatService.sendTextMessage(_controller.text.trim());

    // 2. 로컬 UI 즉각 업데이트 (Optimistic UI 또는 더미 폴백)
    setState(() {
      _dummyMessages.add({
        'type': 'text',
        'sender': '우리동네민우',
        'text': _controller.text.trim(),
        'isMe': true,
        'time': '지금',
      });
      _controller.clear();
    });
    _scrollToBottom();
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
              _buildAttachmentIcon(Icons.image, '사진', Colors.green, onTap: () {
                Navigator.pop(ctx);
                _chatService.sendImage(context); // [동적 기능] 사진 전송
              }),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent, onTap: () {
                Navigator.pop(ctx);
                _chatService.sendLocation(context); // [동적 기능] 위치 공유
              }),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)),
              _buildAttachmentIcon(Icons.local_cafe, '핫플 공유', Colors.brown),
              _buildAttachmentIcon(Icons.directions_car, '동행/드라이브', Colors.indigo),
              _buildAttachmentIcon(Icons.contact_emergency, '안전귀가', Colors.pink),
              _buildAttachmentIcon(Icons.badge, '프로필 교환', Colors.teal),
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

          // [Firebase StreamBuilder 실시간 채팅 연동]
          Expanded(
            child: _firebaseMessageStream == null
                ? _buildDummyMessageList() // Firebase 미설정 시 더미 렌더링
                : StreamBuilder<QuerySnapshot>(
                    stream: _firebaseMessageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildDummyMessageList(); // 데이터 없으면 더미 보여주기
                      }

                      // 새 메시지 도착 시 스크롤 하단 이동 보정
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

  // 동적 문서 타입에 따른 메시지 분기 처리
  Widget _buildDynamicMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    if (type == 'system') return _buildSystemMessage(data['text'] ?? '');
    if (type == 'settlement') return _buildSettlementMessage(data);
    if (type == 'image') return _buildImageMessage(data);
    if (type == 'location') return _buildLocationMessage(data);
    return _buildTextMessage(data);
  }

  // [동적 기능: 사진 메시지 렌더러]
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

  // [동적 기능: 위치 공유 메시지 렌더러 및 url_launcher 외부 연결]
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
                if (!await launchUrl(url)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
                }
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
                      image: const DecorationImage(
                        image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'), // 임시 썸네일
                        fit: BoxFit.cover,
                      ),
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
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: Text('📍 지도에서 위치 보기 (클릭)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
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
          if (isMe) Text(msg['time'], style: TextStyle(fontSize: 10, color: textSecondary)),
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
                Text(msg['title'], style: TextStyle(fontSize: 13, color: textSecondary)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 지출', style: TextStyle(fontSize: 14)),
                    Text('${msg['total']}원', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
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
          if (!isMe) Text(msg['time'], style: TextStyle(fontSize: 10, color: textSecondary)),
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
              child: Text(
                msg['text'] ?? '',
                style: TextStyle(color: isMe ? Colors.white : textPrimary, fontSize: 15, height: 1.4),
              ),
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
    );
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
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
                child: Icon(Icons.add, color: textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '메시지 보내기',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 15),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
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
