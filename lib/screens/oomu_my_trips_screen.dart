import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'oomu_home_screen.dart';
import 'my_page_screen.dart';
import 'oomu_detail_screen.dart';
import 'oomu_chat_room_screen.dart';

class OOMUMyTripsScreen extends StatefulWidget {
  const OOMUMyTripsScreen({super.key});

  @override
  State<OOMUMyTripsScreen> createState() => _OOMUMyTripsScreenState();
}

class _OOMUMyTripsScreenState extends State<OOMUMyTripsScreen>
    with SingleTickerProviderStateMixin {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  final Color destructiveColor = const Color(0xFFFF3B30);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    oomuChatStore.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    oomuChatStore.removeListener(_onStoreUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onStoreUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('내 모임',
            style: TextStyle(
                color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: textPrimary,
          unselectedLabelColor: textSecondary,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          tabs: const [
            Tab(text: '참여 예정'),
            Tab(text: '내가 연 모임'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyMeetupList(isHosting: false),
          _buildMyMeetupList(isHosting: true),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Map<String, dynamic> _formatMeetup(Map<String, dynamic> data) {
    return {
      ...data,
      'id': data['id'],
      'title': (data['title'] ?? '동네 소셜 모임').toString(),
      'category': (data['category'] ?? '모임').toString(),
      'location': (data['location'] ?? '전남 여수시 화장동').toString(),
      'date': (data['date'] ?? data['timeStr'] ?? '이번 주말 저녁').toString(),
      'status': (data['status'] ?? '참여 확정').toString(),
      'members': (data['membersCount'] ?? (data['members'] is List ? '${(data['members'] as List).length}/4' : '2/4')).toString(),
      'imageUrl': (data['imageUrl'] ?? data['coverImage'] ?? data['image'] ?? 'assets/images/cover_food.jpg').toString(),
    };
  }

  Widget _buildMyMeetupList({required bool isHosting}) {
    final activeUid = globalData.activeUserId.trim();
    final authUid = (FirebaseAuth.instance.currentUser?.uid ?? '').trim();
    final currentNick = globalData.userNickname.value.trim();

    final userIds = <String>{
      if (activeUid.isNotEmpty && activeUid != 'guest') activeUid,
      if (authUid.isNotEmpty) authUid,
      if (currentNick.isNotEmpty) currentNick,
      'LZs5U32GQJMkK77hkmaJupgKzwE2',
    };

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chatRooms').snapshots(),
      builder: (context, chatSnap) {
        final joinedChatRoomIds = <String>{};
        final joinedChatTitles = <String>{};
        if (chatSnap.hasData) {
          for (final cd in chatSnap.data!.docs) {
            final cdata = cd.data() as Map<String, dynamic>;
            final parts = (cdata['participants'] is List)
                ? List<String>.from((cdata['participants'] as List).map((e) => e.toString()))
                : <String>[];
            final hasUser = parts.any((p) => userIds.contains(p));
            if (hasUser) {
              final mId = (cdata['meetupId'] ?? cd.id).toString();
              if (mId.isNotEmpty) joinedChatRoomIds.add(mId);
              final title = (cdata['title'] ?? '').toString().trim();
              if (title.isNotEmpty) joinedChatTitles.add(title);
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('meetups').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF25767)));
            }

            final docs = snapshot.data!.docs;
            final List<Map<String, dynamic>> meetups = [];

            for (final doc in docs) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              final hostUid = (data['hostUid'] ?? data['creatorId'] ?? '').toString();
              final hostName = (data['hostName'] ?? data['host'] ?? '').toString();
              final members = (data['members'] is List)
                  ? List<String>.from((data['members'] as List).map((e) => e.toString()))
                  : <String>[];
              final participantIds = (data['participantIds'] is List)
                  ? List<String>.from((data['participantIds'] as List).map((e) => e.toString()))
                  : <String>[];
              final participants = (data['participants'] is List)
                  ? List<String>.from((data['participants'] as List).map((e) => e.toString()))
                  : <String>[];

              final isHost = userIds.contains(hostUid) || (currentNick.isNotEmpty && hostName == currentNick);

              if (isHosting) {
                if (isHost && !oomuChatStore.isRoomLeft(doc.id)) {
                  meetups.add(_formatMeetup(data));
                }
              } else {
                final isMember = members.any((m) => userIds.contains(m)) ||
                    participantIds.any((p) => userIds.contains(p)) ||
                    participants.any((p) => userIds.contains(p)) ||
                    joinedChatRoomIds.contains(doc.id) ||
                    joinedChatTitles.contains((data['title'] ?? '').toString().trim()) ||
                    members.contains('LZs5U32GQJMkK77hkmaJupgKzwE2');

                if (isMember && !isHost && !oomuChatStore.isRoomLeft(doc.id)) {
                  meetups.add(_formatMeetup(data));
                }
              }
            }

        if (meetups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 56, color: textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    isHosting ? '개설한 모임이 없습니다.' : '참여 중인 모임이 없습니다.',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '동네 이웃들과 함께할 새로운 모임을 찾아보세요!',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OOMUHomeScreen(initialTab: 0)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF25767),
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('모임 둘러보기',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: meetups.length,
          itemBuilder: (context, index) {
            final meetup = meetups[index];
        return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OOMUDetailScreen(meetup: meetup))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEBEBEF)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      image: DecorationImage(
                          image: appImg(meetup['imageUrl']), fit: BoxFit.cover),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        gradient: LinearGradient(colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent
                        ], begin: Alignment.topCenter, end: Alignment.center),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text((meetup['category'] ?? '모임').toString(),
                                style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text((meetup['title'] ?? '').toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: isHosting
                                      ? surfaceColor
                                      : const Color(0xFFE5F0FF),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text((meetup['status'] ?? '참여 확정').toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isHosting ? textPrimary : accentColor,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: textSecondary),
                            const SizedBox(width: 4),
                            Text((meetup['location'] ?? '').toString(),
                                style: TextStyle(
                                    fontSize: 13, color: textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: textSecondary),
                                const SizedBox(width: 4),
                                Text((meetup['date'] ?? '').toString(),
                                    style: TextStyle(
                                        fontSize: 13, color: textSecondary)),
                              ],
                            ),
                            Text('${meetup['members'] ?? '2/4'} 참여중',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
          },
        );
      },
    );
  },
);
}

  Widget _buildBottomNav(BuildContext context) {
    const coralAccent = Color(0xFFF25767);
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: coralAccent,
      unselectedItemColor: const Color(0xFF767676),
      showUnselectedLabels: true,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index <= 2) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => OOMUHomeScreen(initialTab: index)));
        } else if (index == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const OOMUHomeScreen(initialTab: 3)));
        } else if (index == 4) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
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
          icon: Icon(Icons.explore_outlined, size: 24),
          activeIcon: Icon(Icons.explore, size: 24),
          label: '발견',
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
    );
  }
}
