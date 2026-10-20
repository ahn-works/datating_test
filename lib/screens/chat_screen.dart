import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_image.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'my_page_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isEmbedded;
  const ChatScreen({super.key, this.isEmbedded = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Color textPrimary = const Color(0xFF221B1D);
  final Color textSecondary = const Color(0xFF635559);
  final Color accentColor = const Color(0xFFF25767);
  final Color backgroundColor = const Color(0xFFFAF6F7);

  final List<Map<String, dynamic>> _defaultChatRooms = [
    {
      'id': 'room_mala_01',
      'title': '주말 엽떡+마라탕 조지실 분 🔥',
      'lastMessage': '홍대입구역 9번 출구 앞에서 봬요!',
      'time': '오후 2:30',
      'unread': 3,
      'members': 4,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isGroup': true,
      'defaultOrder': 1,
    },
    {
      'id': 'room_bowling_02',
      'title': '볼링 에버리지 100 쪼렙팟 🎳',
      'lastMessage': '저 볼링화 240이요~',
      'time': '오전 11:15',
      'unread': 0,
      'members': 6,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isGroup': true,
      'defaultOrder': 2,
    },
    {
      'id': 'room_direct_03',
      'title': '매운맛킬러 (호스트)',
      'lastMessage': '혹시 마라탕 알러지 있으신가요?',
      'time': '어제',
      'unread': 1,
      'members': 2,
      'imageUrl': 'assets/images/kr_female_1.jpg',
      'isGroup': false,
      'defaultOrder': 3,
    },
    {
      'id': 'room_cafe_02',
      'title': '성수 카페 투어 & 디저트 🍰',
      'lastMessage': '이번 주 일요일 2시에 만나요!',
      'time': '오전 10:00',
      'unread': 0,
      'members': 4,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isGroup': true,
      'defaultOrder': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    oomuChatStore.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    oomuChatStore.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Stream<QuerySnapshot>? _getChatRoomsStream() {
    try {
      return FirebaseFirestore.instance
          .collection('chatRooms')
          .orderBy('updatedAt', descending: true)
          .snapshots();
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _mergeAndSortChatRooms(List<QueryDocumentSnapshot>? firestoreDocs) {
    final Map<String, Map<String, dynamic>> map = {};

    // 1. 기본 대화방 장전
    for (var r in _defaultChatRooms) {
      map[r['id']] = Map<String, dynamic>.from(r);
    }

    // 2. Firestore 저장소 대화방 오버레이 및 추가 (신규 개설 모임 포함)
    if (firestoreDocs != null) {
      for (var doc in firestoreDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawId = data['id']?.toString() ?? doc.id;
        final cId = oomuChatStore.canonicalRoomId(rawId);

        DateTime? firestoreTime;
        if (data['updatedAt'] is Timestamp) {
          firestoreTime = (data['updatedAt'] as Timestamp).toDate();
        }

        if (map.containsKey(cId)) {
          if (data['title'] != null && (data['title'] as String).isNotEmpty) {
            map[cId]!['title'] = data['title'];
          }
          if (data['lastMessage'] != null && (data['lastMessage'] as String).isNotEmpty) {
            map[cId]!['lastMessage'] = data['lastMessage'];
          }
          if (data['time'] != null) {
            map[cId]!['time'] = data['time'];
          }
          if (data['members'] != null) {
            map[cId]!['members'] = data['members'];
          }
          if (firestoreTime != null) {
            map[cId]!['updatedAt'] = firestoreTime;
          }
        } else {
          map[cId] = {
            'id': cId,
            'title': data['title'] ?? '새 모임 대화방',
            'lastMessage': data['lastMessage'] ?? '모임 대화방이 개설되었습니다.',
            'time': data['time'] ?? '방금',
            'unread': 0,
            'members': data['members'] ?? 1,
            'imageUrl': data['imageUrl'] ?? 'assets/images/cover_food.jpg',
            'isGroup': data['isGroup'] ?? true,
            'updatedAt': firestoreTime ?? DateTime.now(),
          };
        }
      }
    }

    // 3. 인메모리 oomuChatStore 최신 메시지 및 타임스탬프 동기화
    for (var entry in map.entries) {
      final cId = entry.key;
      final room = entry.value;

      final dynLast = oomuChatStore.getLastMessageText(cId);
      if (dynLast.isNotEmpty) {
        room['lastMessage'] = dynLast;
      }

      final dynTime = oomuChatStore.getLastMessageTime(cId, room['time'] ?? '방금');
      room['time'] = dynTime;

      final dynUpdated = oomuChatStore.getRoomUpdatedAt(cId);
      if (dynUpdated != null) {
        room['updatedAt'] = dynUpdated;
      }
    }

    // 4. 최신 메시지 발송 시간 기준 내림차순(최신순) 정렬 -> 최신 메시지 대화방이 항상 맨 위(0번 인덱스)로 이동
    final list = map.values.toList();
    list.sort((a, b) {
      final aDate = a['updatedAt'] as DateTime?;
      final bDate = b['updatedAt'] as DateTime?;

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }
      if (aDate != null) return -1;
      if (bDate != null) return 1;

      final aOrder = a['defaultOrder'] as int? ?? 99;
      final bOrder = b['defaultOrder'] as int? ?? 99;
      return aOrder.compareTo(bOrder);
    });

    return list;
  }

  Widget _buildChatRoomsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getChatRoomsStream(),
      builder: (context, snapshot) {
        final chatRooms = _mergeAndSortChatRooms(snapshot.data?.docs);

        if (chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 56, color: textSecondary.withOpacity(0.4)),
                const SizedBox(height: 14),
                Text('참여 중인 대화방이 없습니다.', style: TextStyle(color: textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final room = chatRooms[index];
            final unread = room['unread'] as int? ?? 0;
            final members = room['members'] as int? ?? 1;
            final isGroup = room['isGroup'] as bool? ?? (members > 2);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OOMUChatScreen(
                      title: room['title'] ?? '모임 대화방',
                      memberCount: members,
                      chatRoomId: room['id'] ?? 'room_mala_01',
                    ),
                  ),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFE4E6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: appImg(room['imageUrl'] ?? 'assets/images/cover_food.jpg'),
                          backgroundColor: const Color(0xFFFAF6F7),
                        ),
                        if (!isGroup)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const CircleAvatar(radius: 6, backgroundColor: Color(0xFF34C759)),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room['title'] ?? '',
                                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isGroup)
                                Container(
                                  margin: const EdgeInsets.only(left: 6.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$members',
                                    style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            room['lastMessage'] ?? '',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Time & Unread Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          room['time'] ?? '방금',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: unread > 0 ? accentColor : textSecondary,
                            fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
                            decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              '$unread',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          const SizedBox(height: 22),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return Container(
        color: backgroundColor,
        child: _buildChatRoomsList(),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('채팅', style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: textPrimary, size: 24), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildChatRoomsList(),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: BottomNavigationBar(
            currentIndex: 3,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: accentColor,
            unselectedItemColor: const Color(0xFF767676),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            onTap: (index) {
              if (index == 3) return;
              if (index < 3) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUHomeScreen(initialTab: index)));
              } else if (index == 4) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 24),
                label: '동네모임',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined, size: 24),
                activeIcon: Icon(Icons.group, size: 24),
                label: '커뮤니티',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border, size: 24),
                activeIcon: Icon(Icons.favorite, size: 24),
                label: '소개팅',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 23),
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: const BoxDecoration(color: Color(0xFFF25767), shape: BoxShape.circle),
                        child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble, size: 23),
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: const BoxDecoration(color: Color(0xFFF25767), shape: BoxShape.circle),
                        child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                label: '채팅',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24),
                activeIcon: Icon(Icons.person, size: 24),
                label: 'MY',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
