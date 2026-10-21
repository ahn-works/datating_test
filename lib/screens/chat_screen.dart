import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_image.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
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
      'id': 'room_minseo_01',
      'title': '서교동 연트럴파크 산책 팟 🐕 (김민서)',
      'lastMessage': '저녁 7시에 광장 분수대 앞에서 봬요!',
      'time': '방금',
      'unread': 2,
      'members': 3,
      'imageUrl': 'assets/images/kr_female_1.jpg',
      'isGroup': true,
      'defaultOrder': 1,
    },
    {
      'id': 'room_junho_02',
      'title': '성수동 에스프레소 & 러닝 크루 ☕ (이준호)',
      'lastMessage': '이번 주말 카페거리 투어 코스 공유드립니다~',
      'time': '오후 2:30',
      'unread': 1,
      'members': 4,
      'imageUrl': 'assets/images/kr_male_1.jpg',
      'isGroup': true,
      'defaultOrder': 2,
    },
    {
      'id': 'room_jiyeon_03',
      'title': '연남동 숨은 베이킹 투어 🥐 (박지연)',
      'lastMessage': '소금빵 갓 구워져 나왔대요 ㅎㅎ',
      'time': '오전 11:15',
      'unread': 0,
      'members': 2,
      'imageUrl': 'assets/images/kr_female_2.jpg',
      'isGroup': false,
      'defaultOrder': 3,
    },
    {
      'id': 'room_mala_01',
      'title': '주말 엽떡+마라탕 조지실 분 🔥',
      'lastMessage': '홍대입구역 9번 출구 앞에서 봬요!',
      'time': '어제',
      'unread': 0,
      'members': 4,
      'imageUrl': 'assets/images/cover_food.jpg',
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

    // 4. 최신 메시지 발송 시간 기준 내림차순(최신순) 정렬 (나간 방 제외)
    final list = map.values.where((r) => !oomuChatStore.isRoomLeft(r['id']?.toString() ?? '')).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('채팅', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: textPrimary, size: 28), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getChatRoomsStream(),
        builder: (context, snapshot) {
          final chatRooms = _mergeAndSortChatRooms(snapshot.data?.docs);

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('참여 중인 대화방이 없습니다.', style: TextStyle(color: textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (sheetCtx) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: appImg(room['imageUrl'] ?? 'assets/images/cover_food.jpg'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(room['title'] ?? '대화방', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.notifications_off_outlined, color: Color(0xFF767676)),
                            title: const Text('채팅방 알림 끄기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            onTap: () {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('채팅방 알림이 꺼졌습니다.')),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.exit_to_app, color: Color(0xFFE11D48)),
                            title: const Text('대화방 나가기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                            onTap: () {
                              Navigator.pop(sheetCtx);
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.exit_to_app, color: Color(0xFFE11D48)),
                                      SizedBox(width: 8),
                                      Text('대화방 나가기', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  content: Text('\'${room['title']}\' 대화방을 나가시겠습니까?\n나가기를 하면 목록에서 즉시 삭제됩니다.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: const Text('취소', style: TextStyle(color: Color(0xFF767676))),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE11D48),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(dialogCtx);
                                        oomuChatStore.leaveRoom(room['id'] ?? '');
                                        setState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('\'${room['title']}\' 대화방을 나갔습니다.'),
                                            backgroundColor: const Color(0xFF221B1D),
                                          ),
                                        );
                                      },
                                      child: const Text('나가기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: appImg(room['imageUrl'] ?? 'assets/images/cover_food.jpg'),
                            backgroundColor: const Color(0xFFEBEBEF),
                          ),
                          if (!isGroup)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const CircleAvatar(radius: 8, backgroundColor: Colors.green),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(width: 16),

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
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isGroup)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: Text('$members', style: TextStyle(color: textSecondary, fontSize: 14)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              room['lastMessage'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
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
                              fontSize: 12,
                              color: unread > 0 ? accentColor : const Color(0xFFC7C7CC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                '$unread',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
      ),
      bottomNavigationBar: widget.isEmbedded ? null : SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
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
            elevation: 20,
            onTap: (index) {
              if (index <= 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUHomeScreen(initialTab: index)));
              } else if (index == 3) {
                // current chat tab
              } else if (index == 4) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 24),
                label: '동네모임',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined, size: 24),
                activeIcon: Icon(Icons.group, size: 24),
                label: '커뮤니티',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border, size: 24),
                activeIcon: Icon(Icons.favorite, size: 24),
                label: '소개팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline, size: 23),
                activeIcon: Icon(Icons.chat_bubble, size: 23),
                label: '채팅',
              ),
              BottomNavigationBarItem(
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
