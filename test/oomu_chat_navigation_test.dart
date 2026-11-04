import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:spot10_app/services/chat_repository.dart';
import 'package:spot10_app/screens/soso_car_chat_screen.dart';
import 'package:spot10_app/screens/chat_screen.dart';
import 'package:spot10_app/screens/soso_car_home_screen.dart';
import 'package:spot10_app/screens/community_post_detail_screen.dart';
import 'package:spot10_app/screens/community_post_create_screen.dart';
import 'package:spot10_app/screens/my_page_screen.dart';
import 'package:spot10_app/screens/notification_screen.dart';
import 'package:spot10_app/utils/global_data.dart';
import 'package:spot10_app/utils/oomu_ui_helpers.dart';

class FakeChatRepository implements ChatRepository {
  @override
  String? currentUid = 'a';
  final sessions = StreamController<String?>.broadcast();
  final updates = StreamController<List<ChatData>>.broadcast();
  ChatData? roomData = {
    'title': '성수 소소스팟 비스트로 와인 모임',
    'participants': ['a', 'b']
  };
  List<ChatData> initial = [];
  int writes = 0;
  int messageSubscriptions = 0;
  bool failRead = false;
  Completer<void>? sendResult;
  @override
  Stream<String?> get sessionChanges => sessions.stream;
  @override
  Stream<ChatData?> room(String id) => Stream.value(roomData);
  @override
  Stream<List<ChatData>> messages(String id) async* {
    messageSubscriptions++;
    if (failRead) throw StateError('permission-denied');
    yield initial;
    yield* updates.stream;
  }

  @override
  Stream<List<ChatData>> rooms(String uid) => Stream.value(roomData == null
      ? []
      : [
          {...roomData!, 'id': 'r'}
        ]);
  @override
  Future<void> send(String id, ChatData message) async {
    writes++;
    await sendResult?.future;
  }

  @override
  Future<void> updateMessage(String r, String m, ChatData d) async {
    writes++;
  }

  @override
  Future<void> leave(String r) async {
    writes++;
  }

  Future<void> close() async {
    await sessions.close();
    await updates.close();
  }
}

Future<void> showRoom(WidgetTester tester, FakeChatRepository repo,
    {double scale = 1}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(MaterialApp(
      theme: OomuUiHelpers.buildTheme(),
      home: MediaQuery(
          data: MediaQueryData(
              size: const Size(390, 844), textScaler: TextScaler.linear(scale)),
          child: OOMUChatScreen(
              title: '성수 소소스팟 비스트로 와인 모임',
              memberCount: 2,
              chatRoomId: 'r',
              repository: repo))));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => globalData.resetSession());
  test('only exact old seed records are hidden; real content is retained', () {
    final seed = <String, dynamic>{
      'id': 'msg_txt_01',
      'text': '안녕하세요! 다들 마라탕 좋아하시죠?'
    };
    expect(isLegacyChatSeed(seed), isTrue);
    expect(isLegacyChatSeed({...seed, 'senderId': 'real-user'}), isFalse);
    expect(isLegacyChatSeed({...seed, 'id': 'real-message'}), isFalse);
    expect(isLegacyChatSeed({...seed, 'text': '실제 대화'}), isFalse);
    expect(oomuChatStore.getRoomMessages('new-room', '새 모임'), isEmpty);
  });
  test('shared isMe and matching nicknames never determine ownership', () {
    expect(
        presentChatMessage(
            {'isMe': true, 'sender': '우리동네민우', 'senderId': 'b'}, 'a')['isMe'],
        isFalse);
    expect(presentChatMessage({'senderId': 'a'}, 'a')['isMe'], isTrue);
    expect(presentChatMessage({'isMe': true}, null)['isMe'], isFalse);
    expect(
        isChatParticipant({
          'participants': ['a'],
          'leftUserIds': ['a']
        }, 'a'),
        isFalse);
    expect(isChatParticipant({'members': 4}, 'a'), isFalse);
  });
  testWidgets(
      'entering an empty room creates nothing and shows no fabricated cards',
      (tester) async {
    final repo = FakeChatRepository();
    for (final scale in [1.0, 1.3, 2.0]) {
      await showRoom(tester, repo, scale: scale);
      expect(find.text('아직 나눈 대화가 없어요'), findsOneWidget);
      expect(find.textContaining('홍대입구역'), findsNothing);
      expect(find.textContaining('1/N'), findsNothing);
      expect(find.textContaining('시크릿'), findsNothing);
      expect(repo.writes, 0);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await repo.close();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('failed read is not shown as empty or demo conversation',
      (tester) async {
    final repo = FakeChatRepository()..failRead = true;
    await showRoom(tester, repo);
    expect(find.text('대화를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('아직 나눈 대화가 없어요'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await repo.close();
  });
  testWidgets('send waits for persistence and preserves the draft on failure',
      (tester) async {
    final repo = FakeChatRepository()..sendResult = Completer<void>();
    await showRoom(tester, repo);
    await tester.enterText(find.byType(TextField), '실제 입력한 메시지');
    await tester.tap(find.byTooltip('메시지 전송'));
    await tester.pump();
    expect(repo.writes, 1);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '실제 입력한 메시지');
    repo.sendResult!.completeError(StateError('write denied'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '실제 입력한 메시지');
    expect(find.textContaining('메시지를 보내지 못했어요'), findsOneWidget);
    repo.sendResult = null;
    await tester.tap(find.byTooltip('메시지 전송'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    expect(repo.writes, 2);
    await tester.pumpWidget(const SizedBox());
    await repo.close();
  });
  testWidgets(
      'non-members cannot subscribe to messages; logout removes old content and draft',
      (tester) async {
    final repo = FakeChatRepository()..currentUid = 'outsider';
    await showRoom(tester, repo);
    expect(repo.messageSubscriptions, 0);
    expect(find.text('참여 확인이 필요한 대화방이에요'), findsOneWidget);
    repo.currentUid = 'a';
    repo.initial = [
      {'id': 'one', 'senderId': 'b', 'text': '지난 대화'}
    ];
    repo.sessions.add('a');
    await tester.pumpAndSettle();
    expect(find.text('지난 대화'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '전송 전');
    repo.currentUid = null;
    repo.sessions.add(null);
    await tester.pumpAndSettle();
    expect(find.text('지난 대화'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('로그인 후 대화할 수 있어요'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repo.close();
  });
  testWidgets(
      'incoming messages do not drag the reader away from older messages',
      (tester) async {
    final repo = FakeChatRepository()
      ..initial = List.generate(
          30, (i) => {'id': '$i', 'senderId': 'b', 'text': '대화 $i'});
    await showRoom(tester, repo);
    final controller =
        tester.widget<ListView>(find.byType(ListView)).controller!;
    controller.jumpTo(0);
    await tester.pump();
    repo.updates.add([
      ...repo.initial,
      {'id': 'new', 'senderId': 'b', 'text': '새 대화'}
    ]);
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    await tester.pumpWidget(const SizedBox());
    await repo.close();
  });
  testWidgets(
      'five tabs, community detail and composer, and chat return path are reachable',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(MaterialApp(
          theme: OomuUiHelpers.buildTheme(), home: const OOMUHomeScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('커뮤니티').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'community list');
      await tester.tap(find.textContaining('오늘 저녁 연트럴파크 강아지').first);
      await tester.pumpAndSettle();
      expect(find.byType(CommunityPostDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'community detail');
      await tester.tap(find.byTooltip('뒤로가기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('글쓰기').first);
      await tester.pumpAndSettle();
      expect(find.byType(CommunityPostCreateScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'community composer');
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('발견').last);
      await tester.pumpAndSettle();
      expect(find.text('우리 동네 2:2 · 3:3 미팅 팟'), findsOneWidget);
      expect(find.textContaining('동네 미팅 모임은 아직 없어요'), findsOneWidget);
      expect(find.text('미팅 팟 참여하기'), findsNothing);
      expect(find.textContaining('불금 홍대 2:2'), findsNothing);
      expect(tester.takeException(), isNull, reason: 'dating tab');
      await tester.tap(find.text('채팅').last);
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);
      await tester.tap(find.text('동네 모임 둘러보기'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          0);
      await tester.tap(find.text('MY').last);
      await tester.pumpAndSettle();
      expect(find.byType(MyPageScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'MY tab');
      await tester.tap(find.text('커뮤니티').last);
      await tester.pumpAndSettle();
      expect(find.text('글쓰기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets(
      'offline community submission retains input and cannot claim success',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const CommunityPostCreateScreen(currentLocation: '여수 화장동')));
    final fields = find.byType(TextField);
    await tester.enterText(fields.last, '실제로 저장할 글');
    await tester.pump();
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCreateScreen), findsOneWidget);
    expect(find.textContaining('로그인 후 글을 등록'), findsOneWidget);
    expect(tester.widget<TextField>(fields.last).controller!.text, '실제로 저장할 글');
  });
  testWidgets('notification page does not invent approvals or comments',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(), home: const NotificationScreen()));
    await tester.pumpAndSettle();
    expect(find.text('알림 연결을 준비하고 있어요'), findsOneWidget);
    expect(find.textContaining('모임 참여 승인이 완료'), findsNothing);
    expect(find.textContaining('내 글에 새로운 댓글'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
