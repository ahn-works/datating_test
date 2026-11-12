import 'dart:ui';
import 'screens/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/oomu_home_screen.dart';
import 'screens/oomu_detail_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/community_post_detail_screen.dart';
import 'screens/community_post_create_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/oomu_chat_room_screen.dart';
import 'screens/login_screen.dart';
import 'services/r2_storage_service.dart';
import 'utils/global_data.dart';
import 'ui/oomu_tokens.dart';
import 'ui/oomu_component_gallery.dart';
import 'utils/oomu_ui_helpers.dart';
import 'widgets/oomu_discovery_lifestyle_hub.dart';

void main() async {
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
    await r2Storage.initFromFirestore();
  } catch (e) {
    debugPrint("Firebase/R2 init error: $e");
  }
  runApp(const Spot10App());
}

class Spot10App extends StatelessWidget {
  const Spot10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOMU',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      theme: OomuUiHelpers.buildTheme(),
      builder: (context, child) => Container(
        color: OomuTokens.surfaceMuted,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: OomuTokens.appFrameMaxWidth),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(
                  MediaQuery.of(context).size.width > 480
                      ? 480
                      : MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: OomuTokens.background,
                  boxShadow: MediaQuery.of(context).size.width > 480
                      ? [
                          BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.12),
                            blurRadius: 32,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                child: child!,
              ),
            ),
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final uri = Uri.base;
          final isHome = uri.queryParameters['home'] == 'true' || uri.fragment.contains('home=true');
          final isGallery = uri.queryParameters['gallery'] == 'true' || uri.fragment.contains('gallery=true');
          final isDetail = uri.queryParameters['detail'] == 'true' || uri.fragment.contains('detail=true');
          final isMy = uri.queryParameters['my'] == 'true' || uri.fragment.contains('my=true');
          final isProfile = uri.queryParameters['profile'] == 'true' || uri.fragment.contains('profile=true');
          final isEdit = uri.queryParameters['edit'] == 'true' || uri.fragment.contains('edit=true');
          final isCommDetail = uri.queryParameters['comm_detail'] == 'true' || uri.fragment.contains('comm_detail=true');
          final isCommCreate = uri.queryParameters['comm_create'] == 'true' || uri.fragment.contains('comm_create=true');
          final isChat = uri.queryParameters['chat'] == 'true' || uri.fragment.contains('chat=true');
          final isChatRoom = uri.queryParameters['chat_room'] == 'true' || uri.fragment.contains('chat_room=true');
          final isDiscovery = uri.queryParameters['discovery'] == 'true' || uri.fragment.contains('discovery=true');
          final isFortune = uri.queryParameters['fortune'] == 'true' || uri.fragment.contains('fortune=true');
          final isLogin = uri.queryParameters['login'] == 'true' || uri.fragment.contains('login=true');
          final isProfileSetup = uri.queryParameters['profile_setup'] == 'true' || uri.fragment.contains('profile_setup=true');
          final targetUser = uri.queryParameters['user'] ?? (uri.fragment.contains('user=test11') ? 'test11' : '');

          if (isGallery) {
            return const OomuComponentGallery();
          }
          if (isHome) {
            if (targetUser == 'test11' || targetUser == 'choyeon') {
              globalData.switchUser('LZs5U32GQJMkK77hkmaJupgKzwE2');
            } else {
              globalData.switchUser('guest');
            }
            return const OOMUHomeScreen();
          }
          if (isMy) {
            if (targetUser == 'test11' || targetUser == 'choyeon') {
              globalData.switchUser('LZs5U32GQJMkK77hkmaJupgKzwE2');
            } else {
              globalData.switchUser('guest');
            }
            return const MyPageScreen();
          }
          if (isProfile) {
            if (targetUser == 'test11' || targetUser == 'choyeon') {
              globalData.switchUser('LZs5U32GQJMkK77hkmaJupgKzwE2');
              return const UserProfileScreen(
                userName: '우리동네_초연',
                userAge: '29',
                userLocation: '전남 여수시 화장동',
                userBio:
                    '여수 화장동 토박이 초연입니다! 동네 산책과 감성 카페 모임 좋아해요 😊 (R2 실시간 연동 테스트 완료)',
                userAvatar: 'profiles/초연.png',
                userJob: '프리랜서 디자이너',
                userMbti: 'ENFP',
                userDrinking: ['가볍게 한잔'],
                userPersonalities: ['리액션 요정', '친화력 갑'],
                userHobbies: ['맛집탐방', '보드게임'],
                userSmoking: '비흡연',
                userPet: '반려동물 있음',
                userGender: '여성',
                isSelf: true,
              );
            }
            globalData.switchUser('guest');
            return const UserProfileScreen(userName: '김민서');
          }
          if (isEdit) {
            if (targetUser == 'test11' || targetUser == 'choyeon') {
              globalData.switchUser('LZs5U32GQJMkK77hkmaJupgKzwE2');
            } else {
              globalData.switchUser('guest');
            }
            return const ProfileEditScreen();
          }
          if (isLogin) {
            return const LoginScreen();
          }
          if (isProfileSetup) {
            return const ProfileSetupScreen();
          }
          if (isCommCreate) {
            globalData.switchUser('guest');
            return const CommunityPostCreateScreen();
          }
          if (isChat) {
            globalData.switchUser('guest');
            return const ChatScreen();
          }
          if (isChatRoom) {
            globalData.switchUser('guest');
            return const OOMUChatScreen(
              title: '주말 엽떡+마라탕 팟 🔥',
              memberCount: 4,
              chatRoomId: 'sample_chat_room_01',
            );
          }
          if (isDiscovery) {
            globalData.switchUser('guest');
            return const Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: OomuDiscoveryLifestyleHub(
                  currentLocation: '전남 여수시 화장동',
                  initialCategoryIndex: 0,
                ),
              ),
            );
          }
          if (isFortune) {
            globalData.switchUser('guest');
            return const Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: OomuDiscoveryLifestyleHub(
                  currentLocation: '전남 여수시 화장동',
                  initialCategoryIndex: 5,
                ),
              ),
            );
          }
          if (isCommDetail) {
            globalData.switchUser('guest');
            return const CommunityPostDetailScreen(post: {
              'id': 'post_sample_01',
              'category': '맛집·카페',
              'title': '망원동 조용한 작업용 북카페 추천해요 ☕',
              'content': '망원시장 근처에 콘센트 많고 잔잔한 재즈 음악 나오는 북카페 찾았어요. 주말에도 너무 시끄럽지 않아서 독서나 가벼운 노트북 작업하기 딱 좋습니다!',
              'author': '망원러너_민우',
              'authorAvatar': 'assets/images/민지.png',
              'location': '마포구 망원동',
              'time': '15분 전',
              'likes': 12,
              'comments': 2,
              'commentList': [
                {
                  'id': 'c_01',
                  'author': '연남책방러',
                  'content': '오 혹시 드립커피 맛은 어떤가요? 저도 가보고 싶네요!',
                  'time': '10분 전',
                  'likes': 2,
                  'isLiked': false,
                },
                {
                  'id': 'c_02',
                  'author': '망원동주민',
                  'content': '여기 사장님도 친절하시고 쿠키도 맛있어요 ㅎㅎ',
                  'time': '5분 전',
                  'likes': 1,
                  'isLiked': false,
                }
              ],
            });
          }
          if (isDetail) {
            globalData.switchUser('guest');
            return const OOMUDetailScreen(meetup: {
              'id': 'sample_01',
              'title': '주말 엽떡+마라탕+꿔바로우 털러 가실 파티원 🔥',
              'category': '맛집·카페',
              'location': '마포구 서교동 홍대입구역 9번 출구',
              'date': '이번주 토요일 저녁 6시',
              'time': '저녁 6시',
              'transport': '대중교통 / 각자 이동',
              'fee': '각자 주문 (1/N)',
              'cost': '각자 주문 (1/N)',
              'members': 2,
              'maxMembers': 4,
              'host': '망원러너_민우',
              'hostAvatar': 'assets/images/민지.png',
              'hostBio': '맛있는 음식 먹으며 즐겁게 이야기 나누는 모임 좋아해요!',
              'hostManner': 46.5,
              'isVerified': true,
              'isFemaleOnly': true,
              'description': '홍대 근처 마라탕과 엽떡 맛집 같이 가실 분 구해요! 매운 음식 좋아하시는 분 환영합니다. 편하게 신청해 주세요 :)',
              'imageUrl': 'assets/images/cover_food.jpg',
              'praiseTags': ['친절하고 배려심 넘쳐요', '시간 약속을 잘 지켜요', '분위기를 밝게 해줘요'],
            });
          }
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: OomuTokens.background,
                  body: Center(
                    child: CircularProgressIndicator(color: OomuTokens.coral),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!;
                globalData.switchUser(user.uid);
                return _AuthGate(user: user);
              }
              globalData.switchUser('guest');
              return const LoginScreen();
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final User user;
  const _AuthGate({required this.user});

  @override
  Widget build(BuildContext context) {
    if (authService.isAdmin) {
      return const OOMUHomeScreen();
    }
    return FutureBuilder<bool>(
      future: authService.isUserProfileComplete(user.uid),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: OomuTokens.background,
            body: Center(
              child: CircularProgressIndicator(color: OomuTokens.coral),
            ),
          );
        }
        if (profileSnapshot.data == false) {
          return const ProfileSetupScreen();
        }
        return const OOMUHomeScreen();
      },
    );
  }
}
