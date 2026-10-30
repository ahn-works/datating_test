import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';
import '../widgets/bouncy_tap.dart';

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

  // 더미 하드코딩 대화방 제거 -> 사용자가 실제 참여한 방만 Firestore에서 순수 표시
  final List<Map<String, dynamic>> _defaultChatRooms = [];

  @override
  void initState() {
    super.initState();
    oomuChatStore.addListener(_onStoreUpdate);
    _syncUserStates();
  }

  void _syncUserStates() {
    try {
      final myUid = authService.currentUser?.uid ?? globalData.currentUserId.value;
      if (myUid.isNotEmpty) {
        oomuChatStore.syncWithCurrentUser(myUid);
        FirebaseFirestore.instance
            .collection('user_states')
            .doc(myUid)
            .snapshots()
            .listen((snap) {
          if (mounted) setState(() {});
        });
      }
    } catch (_) {}
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
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final rawId = data['id']?.toString() ?? doc.id;
        final cId = oomuChatStore.canonicalRoomId(rawId);

        // 빈 데이터 오버레이 방지 (유효한 방 이름이 없을 경우)
        final String? title = data['title'];
        if (title == null || title.trim().isEmpty) continue;

        DateTime? firestoreTime;
        if (data['updatedAt'] is Timestamp) {
          firestoreTime = (data['updatedAt'] as Timestamp).toDate();
        }

        if (map.containsKey(cId)) {
          if (title.isNotEmpty) {
            map[cId]!['title'] = title;
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
          if (data['leftUserIds'] != null) {
            map[cId]!['leftUserIds'] = data['leftUserIds'];
          }
          if (firestoreTime != null) {
            map[cId]!['updatedAt'] = firestoreTime;
          }
        } else {
          map[cId] = {
            'id': cId,
            'title': title,
            'lastMessage': data['lastMessage'] ?? '모임 대화방이 개설되었습니다.',
            'time': data['time'] ?? '방금',
            'unread': 0,
            'members': data['members'] ?? 1,
            'imageUrl': data['imageUrl'] ?? 'assets/images/cover_food.jpg',
            'isGroup': data['isGroup'] ?? true,
            'leftUserIds': data['leftUserIds'],
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

    // 4. 최신 메시지 발송 시간 기준 내림차순(최신순) 정렬 (A가 나간 방은 A한테만 영구 제외, B/C/E한테는 유지)
    final myUid = authService.currentUser?.uid ?? globalData.currentUserId.value;
    final list = map.values.where((r) {
      final rid = r['id']?.toString() ?? '';
      // 1) 내 메모리/user_states 상 나간 방이면 내 화면에서 제외
      if (oomuChatStore.isRoomLeft(rid)) return false;

      // 2) Firestore 대화방의 leftUserIds에 내 UID가 있으면 내 화면에서 영구 제외
      final leftUsers = List<dynamic>.from(r['leftUserIds'] ?? []);
      if (myUid.isNotEmpty && leftUsers.contains(myUid)) return false;

      return true;
    }).toList();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: accentColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '참여 중인 대화방이 없어요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '동네 모임에 참여하여\n이웃들과 즐거운 대화를 시작해 보세요! ☕',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.explore_rounded, size: 18),
                      label: const Text('동네 모임 둘러보기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const OOMUHomeScreen(initialTab: 0)),
                        );
                      },
                    ),
                  ],
                ),
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

              return BouncyTap(
                scaleDown: 0.98,
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
                  OomuHaptics.heavy();
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
