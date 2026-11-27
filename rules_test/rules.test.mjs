// Firestore 보안 규칙 에뮬레이터 테스트 (체크리스트 2번)
//
// - 대상: 레포 루트 firestore.rules (이 파일은 규칙을 읽기만 하고 바꾸지 않는다)
// - 시나리오: 앱(lib/)이 실제로 보내는 읽기·쓰기 모양을 그대로 흉내 낸다.
//   각 테스트 이름 끝의 [파일:줄]이 근거가 되는 클라이언트 코드 위치다.
// - `todo` 로 표시한 테스트는 "이렇게 동작해야 한다"는 기대를 적은 것이고,
//   현재 규칙에서는 실패한다(= 규칙 결함). node:test 는 todo 실패를 전체 실패로
//   세지 않으므로 CI 는 통과하지만, 결과에 '# TODO' 로 남는다.
//   규칙이 고쳐지면 todo 를 지워 일반 테스트로 승격한다.
// - 2026-11-27 운영 게시본 반영: 결함 R1·R2·R4~R8 테스트는 필수 통과로 승격.
//   남은 todo 는 인증 배지(R3) 1건뿐이다(체크리스트 3번 서버 OTP 이후).
//
// 실행: cd rules_test && npm ci && npm test
// 가짜 프로젝트(demo-*)만 쓰므로 운영 Firebase 에 접속하지 않는다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  arrayRemove,
  arrayUnion,
  collection,
  deleteDoc,
  doc,
  documentId,
  getDoc,
  getDocs,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
  addDoc,
} from 'firebase/firestore';

const here = dirname(fileURLToPath(import.meta.url));
// RULES_FILE 로 다른 규칙 파일(수정 제안본 등)을 같은 시나리오로 돌려볼 수 있다.
const RULES_PATH = process.env.RULES_FILE
  ? resolve(process.env.RULES_FILE)
  : resolve(here, '..', 'firestore.rules');

const ALICE = 'uid_alice'; // 일반 사용자 (글쓴이·모임장 역할)
const BOB = 'uid_bob'; // 일반 사용자 (다른 사람)
const CAROL = 'uid_carol'; // 제3자
const ADMIN = 'uid_admin'; // token.admin == true

let env;

const anon = () => env.unauthenticatedContext().firestore();
const as = (uid) => env.authenticatedContext(uid).firestore();
const asAdmin = () => env.authenticatedContext(ADMIN, { admin: true }).firestore();

// 규칙을 거치지 않고 초기 데이터를 넣는다.
async function seed(fn) {
  await env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({
    projectId: 'demo-oomu-rules',
    firestore: { rules: readFileSync(RULES_PATH, 'utf8'), host, port: Number(port) },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
});

after(async () => {
  await env?.cleanup();
});

// ---------------------------------------------------------------------------
describe('1. 시크릿 문서 차단 (config / system_config / phone_verifications / app_config)', () => {
  beforeEach(() =>
    seed(async (db) => {
      await setDoc(doc(db, 'config/r2_storage'), { secretAccessKey: 'dummy' });
      await setDoc(doc(db, 'config/api_keys'), { k: 'dummy' });
      await setDoc(doc(db, 'system_config/r2_storage'), { k: 'dummy' });
      await setDoc(doc(db, 'phone_verifications/01000000000'), { code: '000000' });
      await setDoc(doc(db, 'app_config/r2_public'), { publicUrl: 'https://example.invalid' });
      for (const id of ['solapi', 'api_keys', 'r2_storage', 'naver', 'naver_auth']) {
        await setDoc(doc(db, `app_config/${id}`), { k: 'dummy' });
      }
      await setDoc(doc(db, 'app_config/notice'), { text: '점검 안내' });
    }));

  for (const path of ['config/r2_storage', 'config/api_keys', 'system_config/r2_storage', 'phone_verifications/01000000000']) {
    test(`비로그인·로그인·관리자 모두 ${path} 읽기 거부`, async () => {
      await assertFails(getDoc(doc(anon(), path)));
      await assertFails(getDoc(doc(as(ALICE), path)));
      await assertFails(getDoc(doc(asAdmin(), path)));
    });
  }

  test('로그인 사용자의 config/kakao_auth 쓰기 거부 [auth_service.dart:151]', async () => {
    await assertFails(setDoc(doc(as(ALICE), 'config/kakao_auth'), { kakaoRestApiKey: 'x' }, { merge: true }));
  });

  test('app_config/r2_public 은 비로그인도 get 허용, 쓰기 거부', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'app_config/r2_public')));
    await assertFails(setDoc(doc(as(ALICE), 'app_config/r2_public'), { publicUrl: 'x' }));
  });

  for (const id of ['solapi', 'api_keys', 'r2_storage', 'naver', 'naver_auth']) {
    test(`app_config/${id} get 거부`, async () => {
      await assertFails(getDoc(doc(as(ALICE), `app_config/${id}`)));
    });
  }

  test('app_config 일반 문서 get 허용, 컬렉션 list 거부', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'app_config/notice')));
    await assertFails(getDocs(collection(as(ALICE), 'app_config')));
  });

  test('naver_region_places: get 허용, list·쓰기 거부', async () => {
    await seed((db) => setDoc(doc(db, 'naver_region_places/h1'), { places: [] }));
    await assertSucceeds(getDoc(doc(anon(), 'naver_region_places/h1')));
    await assertFails(getDocs(collection(anon(), 'naver_region_places')));
    await assertFails(setDoc(doc(as(ALICE), 'naver_region_places/h1'), { places: [1] }));
  });

  test('규칙에 없는 경로는 기본 거부', async () => {
    await assertFails(setDoc(doc(as(ALICE), 'random_collection/x'), { a: 1 }));
    await assertFails(getDoc(doc(as(ALICE), 'random_collection/x')));
  });
});

// ---------------------------------------------------------------------------
describe('2. users / private / user_states', () => {
  // auth_service.dart:919 신규 가입 시 users 문서 생성 페이로드(요약)
  const newUserDoc = (uid) => ({
    userId: uid,
    role: 'user',
    name: '회원',
    nickname: '우리동네_테스트',
    gender: '',
    location: '',
    photoUrl: '',
    avatarUrl: '',
    photoUrls: [],
    mannerTemp: 36.5,
    isVerified: false,
    isPhoneVerified: false,
    isProfileComplete: false,
    provider: 'email',
    isGuest: false,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  test('본인 users 문서 생성 허용 [auth_service.dart:919]', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), `users/${ALICE}`), newUserDoc(ALICE)));
  });

  test('남의 uid 로 users 문서 생성 거부', async () => {
    await assertFails(setDoc(doc(as(ALICE), `users/${BOB}`), newUserDoc(BOB)));
  });

  test('users 문서에 phone / phoneNumber / email 을 넣어 생성하면 거부', async () => {
    await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { ...newUserDoc(ALICE), phone: '01000000000' }));
    await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { ...newUserDoc(ALICE), phoneNumber: '01000000000' }));
    await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { ...newUserDoc(ALICE), email: 'choyeon@test.oomu.app' }));
  });

  test('관리자 claim 없이 role: admin 으로 생성 거부, claim 있으면 허용', async () => {
    await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { ...newUserDoc(ALICE), role: 'admin' }));
    await assertSucceeds(setDoc(doc(asAdmin(), `users/${ADMIN}`), { ...newUserDoc(ADMIN), role: 'admin' }));
  });

  test('guest 문서는 생성·조회 거부', async () => {
    await assertFails(setDoc(doc(as(ALICE), 'users/guest'), { a: 1 }));
    await assertFails(getDoc(doc(as(ALICE), 'users/guest')));
  });

  describe('기존 문서가 있을 때', () => {
    beforeEach(() =>
      seed(async (db) => {
        await setDoc(doc(db, `users/${ALICE}`), newUserDoc(ALICE));
        await setDoc(doc(db, `users/${BOB}`), newUserDoc(BOB));
        await setDoc(doc(db, `users/${ALICE}/private/contact`), { phone: '01000000000' });
        await setDoc(doc(db, `users/${ALICE}/notifications/n1`), { title: 't' });
        await setDoc(doc(db, `user_states/${ALICE}`), { blockedUids: [] });
      }));

    test('로그인 사용자는 남의 공개 프로필 get 허용', async () => {
      await assertSucceeds(getDoc(doc(as(BOB), `users/${ALICE}`)));
    });

    // 현재 앱 흐름을 지키는 테스트. 인증 배지를 서버가 쓰게 되면(아래 todo) 이 테스트를 assertFails 로 뒤집는다.
    test('본인 merge 업데이트(isPhoneVerified) 허용 [phone_verification_field.dart:225]', async () => {
      await assertSucceeds(
        setDoc(doc(as(ALICE), `users/${ALICE}`), { isPhoneVerified: true, updatedAt: serverTimestamp() }, { merge: true }),
      );
    });

    test('본인 myPostsCount 증가 허용 [community_post_create_screen.dart:220]', async () => {
      await assertSucceeds(
        setDoc(doc(as(ALICE), `users/${ALICE}`), { myPostsCount: 1 }, { merge: true }),
      );
    });

    test('남의 users 문서 수정 거부', async () => {
      await assertFails(setDoc(doc(as(BOB), `users/${ALICE}`), { nickname: '해킹' }, { merge: true }));
    });

    test('본인이어도 phone 필드 추가·role 변경은 거부', async () => {
      await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { phone: '01000000000' }, { merge: true }));
      await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { role: 'admin' }, { merge: true }));
    });

    test('private/contact: 본인 읽기·쓰기 허용, 타인·비로그인 거부 [auth_service.dart:1124]', async () => {
      await assertSucceeds(getDoc(doc(as(ALICE), `users/${ALICE}/private/contact`)));
      await assertSucceeds(
        setDoc(doc(as(ALICE), `users/${ALICE}/private/contact`), { phone: '01000000000' }, { merge: true }),
      );
      await assertFails(getDoc(doc(as(BOB), `users/${ALICE}/private/contact`)));
      await assertFails(getDoc(doc(anon(), `users/${ALICE}/private/contact`)));
    });

    test('users/{uid}/notifications: 본인 읽기 허용, 쓰기 거부', async () => {
      await assertSucceeds(getDoc(doc(as(ALICE), `users/${ALICE}/notifications/n1`)));
      await assertFails(getDoc(doc(as(BOB), `users/${ALICE}/notifications/n1`)));
      await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}/notifications/n2`), { title: 'x' }));
    });

    test('user_states: 본인 차단 목록 저장 허용, 타인 읽기 거부 [global_data.dart:605]', async () => {
      await assertSucceeds(
        setDoc(doc(as(ALICE), `user_states/${ALICE}`), { blockedUids: arrayUnion(BOB), updatedAt: serverTimestamp() }, { merge: true }),
      );
      await assertFails(getDoc(doc(as(BOB), `user_states/${ALICE}`)));
    });

    // ---- 규칙 결함(백엔드 필요) ----
    test(
      '탈퇴 시 본인 users 문서 삭제가 되어야 한다 [auth_service.dart:199]',
      async () => {
        await assertSucceeds(deleteDoc(doc(as(ALICE), `users/${ALICE}`)));
      },
    );

    test(
      '본인이 mannerTemp 를 임의로 올릴 수 없어야 한다',
      async () => {
        await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { mannerTemp: 99 }, { merge: true }));
      },
    );

    test(
      '본인이 isVerified / isPhoneVerified 를 임의로 켤 수 없어야 한다',
      { todo: '백엔드 필요(체크리스트 3번 이후): 인증 배지를 앱이 직접 씀 [phone_verification_field.dart:225, auth_service.dart:400]. 서버 OTP 검증 후 서버가 쓰도록 옮긴 뒤에 규칙으로 잠가야 함' },
      async () => {
        await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { isVerified: true }, { merge: true }));
        await assertFails(setDoc(doc(as(ALICE), `users/${ALICE}`), { isPhoneVerified: true }, { merge: true }));
      },
    );

    test('비로그인 상태에서 필터 없는 users 목록 조회는 거부 (guest 조건을 증명 못 함)', async () => {
      await assertFails(getDocs(collection(anon(), 'users')));
    });

    test('비로그인 상태에서 문서 ID 필터(!= guest)를 붙인 users 목록 조회도 거부', async () => {
      await assertFails(getDocs(query(collection(anon(), 'users'), where(documentId(), '!=', 'guest'))));
    });

    test('비로그인이어도 uid 를 알면 users 문서 개별 get 은 허용 (현재 동작 기록)', async () => {
      await assertSucceeds(getDoc(doc(anon(), `users/${ALICE}`)));
    });
  });
});

// ---------------------------------------------------------------------------
describe('3. community_posts / comments (좋아요 = 체크리스트 12번)', () => {
  const post = (author) => ({
    authorId: author,
    title: '와플집 가보신 분',
    content: '본문',
    category: '자유',
    likes: 0,
    likedUserIds: [],
    createdAt: serverTimestamp(),
  });

  test('비로그인 읽기 허용, 비로그인 글쓰기 거부', async () => {
    await seed((db) => setDoc(doc(db, 'community_posts/p1'), post(ALICE)));
    await assertSucceeds(getDoc(doc(anon(), 'community_posts/p1')));
    await assertFails(setDoc(doc(anon(), 'community_posts/p2'), post(ALICE)));
  });

  test('본인 authorId 로 글쓰기 허용, 남의 authorId 로 글쓰기 거부', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), 'community_posts/p1'), post(ALICE)));
    await assertFails(setDoc(doc(as(ALICE), 'community_posts/p2'), post(BOB)));
  });

  test(
    'userId 만 본인으로 두고 authorId 를 남으로 넣어 글쓰기는 거부되어야 한다',
    async () => {
      await assertFails(setDoc(doc(as(ALICE), 'community_posts/p3'), { ...post(BOB), userId: ALICE }));
    },
  );

  describe('좋아요', () => {
    beforeEach(() =>
      seed(async (db) => {
        await setDoc(doc(db, 'community_posts/p1'), post(ALICE));
        await setDoc(doc(db, 'community_posts/p1/comments/c1'), {
          authorId: ALICE, content: '댓글', likes: 0, likedUserIds: [],
        });
        // likedUserIds 필드가 없는 예전 글
        const legacy = post(ALICE);
        delete legacy.likedUserIds;
        await setDoc(doc(db, 'community_posts/legacy'), legacy);
      }));

    // community_like_service.dart:10 과 같은 트랜잭션
    const toggleLike = (db, path, uid, liked) =>
      runTransaction(db, async (tx) => {
        const ref = doc(db, path);
        const snap = await tx.get(ref);
        const ids = new Set(Array.isArray(snap.data()?.likedUserIds) ? snap.data().likedUserIds : []);
        const changed = liked ? !ids.has(uid) && ids.add(uid) : ids.delete(uid);
        if (changed) tx.update(ref, { likedUserIds: [...ids], likes: ids.size });
      });

    test('남의 글에 좋아요 → 취소 허용 [community_like_service.dart:17]', async () => {
      await assertSucceeds(toggleLike(as(BOB), 'community_posts/p1', BOB, true));
      await assertSucceeds(toggleLike(as(BOB), 'community_posts/p1', BOB, false));
    });

    test('두 사람이 연달아 좋아요 → likes 2', async () => {
      await assertSucceeds(toggleLike(as(BOB), 'community_posts/p1', BOB, true));
      await assertSucceeds(toggleLike(as(CAROL), 'community_posts/p1', CAROL, true));
      const snap = await getDoc(doc(as(ALICE), 'community_posts/p1'));
      if (snap.data().likes !== 2) throw new Error(`likes=${snap.data().likes}`);
    });

    test('likedUserIds 필드가 없는 예전 글에도 좋아요 허용', async () => {
      await assertSucceeds(toggleLike(as(BOB), 'community_posts/legacy', BOB, true));
    });

    test('남의 댓글에 좋아요 허용', async () => {
      await assertSucceeds(toggleLike(as(BOB), 'community_posts/p1/comments/c1', BOB, true));
    });

    test('다른 사람 uid 를 대신 넣는 좋아요 거부', async () => {
      await assertFails(updateDoc(doc(as(BOB), 'community_posts/p1'), { likedUserIds: [CAROL], likes: 1 }));
    });

    test('likes 숫자를 likedUserIds 길이와 다르게 넣으면 거부 (숫자 부풀리기 차단)', async () => {
      await assertFails(updateDoc(doc(as(BOB), 'community_posts/p1'), { likedUserIds: [BOB], likes: 100 }));
    });

    test('같은 uid 중복 추가 거부, 음수 불가', async () => {
      await assertFails(updateDoc(doc(as(BOB), 'community_posts/p1'), { likedUserIds: [BOB, BOB], likes: 2 }));
      await assertFails(updateDoc(doc(as(BOB), 'community_posts/p1'), { likedUserIds: [], likes: -1 }));
    });

    test('좋아요와 함께 본문 수정 시도 거부', async () => {
      await assertFails(
        updateDoc(doc(as(BOB), 'community_posts/p1'), { likedUserIds: [BOB], likes: 1, content: '변조' }),
      );
    });
  });

  describe('수정·삭제·댓글', () => {
    beforeEach(() => seed((db) => setDoc(doc(db, 'community_posts/p1'), post(ALICE))));

    test('글쓴이 수정·삭제 허용, 다른 사람 수정·삭제 거부', async () => {
      await assertFails(updateDoc(doc(as(BOB), 'community_posts/p1'), { content: '변조' }));
      await assertFails(deleteDoc(doc(as(BOB), 'community_posts/p1')));
      await assertSucceeds(updateDoc(doc(as(ALICE), 'community_posts/p1'), { content: '수정' }));
      await assertSucceeds(deleteDoc(doc(as(ALICE), 'community_posts/p1')));
    });

    test('관리자 삭제 허용', async () => {
      await assertSucceeds(deleteDoc(doc(asAdmin(), 'community_posts/p1')));
    });

    test('댓글 작성 허용 [community_post_detail_screen.dart:203], 남 명의 댓글 거부', async () => {
      await assertSucceeds(
        setDoc(doc(as(BOB), 'community_posts/p1/comments/c1'), {
          authorId: BOB, author: '밥', content: '좋아요', likes: 0, likedUserIds: [], createdAt: serverTimestamp(),
        }),
      );
      await assertFails(
        setDoc(doc(as(BOB), 'community_posts/p1/comments/c2'), { authorId: ALICE, content: '사칭' }),
      );
    });

    test('남의 댓글 삭제 거부, 본인 댓글 삭제 허용', async () => {
      await seed((db) => setDoc(doc(db, 'community_posts/p1/comments/c1'), { authorId: BOB, content: 'x' }));
      await assertFails(deleteDoc(doc(as(CAROL), 'community_posts/p1/comments/c1')));
      await assertSucceeds(deleteDoc(doc(as(BOB), 'community_posts/p1/comments/c1')));
    });
  });
});

// ---------------------------------------------------------------------------
describe('4. meetups / applications / 모임 채팅방 생성', () => {
  const meetup = (host) => ({
    hostUid: host,
    title: '화장동 보드게임',
    location: '여수시 화장동',
    date: '2026-12-01',
    capacity: 4,
    occupiedSeats: 1,
    participantIds: [host],
    members: [host],
  });

  test('모임 개설 + 단톡방 생성 batch 허용 [oomu_host_screen.dart:570]', async () => {
    const db = as(ALICE);
    const batch = writeBatch(db);
    batch.set(doc(db, 'meetups/m1'), meetup(ALICE));
    batch.set(doc(db, 'chatRooms/m1'), {
      id: 'm1', meetupId: 'm1', hostUid: ALICE, participants: [ALICE], isGroup: true, lastMessage: '',
    });
    await assertSucceeds(batch.commit());
  });

  test('남의 hostUid 로 모임 개설 거부', async () => {
    await assertFails(setDoc(doc(as(ALICE), 'meetups/m1'), meetup(BOB)));
  });

  test('모임장이 아닌데 meetupId 가 붙은 채팅방 생성 거부', async () => {
    await seed((db) => setDoc(doc(db, 'meetups/m1'), meetup(ALICE)));
    await assertFails(
      setDoc(doc(as(BOB), 'chatRooms/m1'), { meetupId: 'm1', hostUid: BOB, participants: [BOB] }),
    );
  });

  describe('참여 신청', () => {
    beforeEach(() => seed((db) => setDoc(doc(db, 'meetups/m1'), meetup(ALICE))));

    const application = (uid, extra = {}) => ({
      userId: uid, nickname: '밥', message: '참여할게요', partySize: 1, status: 'pending',
      createdAt: serverTimestamp(), ...extra,
    });

    test('본인 신청(pending, 1~2명) 허용 [meetup_application_service.dart:58]', async () => {
      await assertSucceeds(setDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`), application(BOB)));
    });

    test('신청자가 모임 문서에 직접 자기 자리를 넣는 것은 거부', async () => {
      await assertFails(
        updateDoc(doc(as(BOB), 'meetups/m1'), { participantIds: arrayUnion(BOB), occupiedSeats: 2 }),
      );
    });

    test('승인 상태로 신청·3명 신청·남의 uid 로 신청 거부', async () => {
      await assertFails(setDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`), application(BOB, { status: 'approved' })));
      await assertFails(setDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`), application(BOB, { partySize: 3 })));
      await assertFails(setDoc(doc(as(BOB), `meetups/m1/applications/${CAROL}`), application(CAROL)));
    });

    describe('신청서가 있을 때', () => {
      beforeEach(() =>
        seed((db) => setDoc(doc(db, `meetups/m1/applications/${BOB}`), application(BOB))));

      test('신청자 본인·모임장 get 허용, 제3자 get 거부', async () => {
        await assertSucceeds(getDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`)));
        await assertSucceeds(getDoc(doc(as(ALICE), `meetups/m1/applications/${BOB}`)));
        await assertFails(getDoc(doc(as(CAROL), `meetups/m1/applications/${BOB}`)));
      });

      test('모임장 pending 목록 조회 허용, 제3자 목록 조회 거부 [meetup_participation_action.dart:161]', async () => {
        const q = (db) => query(collection(db, 'meetups/m1/applications'), where('status', '==', 'pending'));
        await assertSucceeds(getDocs(q(as(ALICE))));
        await assertFails(getDocs(q(as(CAROL))));
      });

      test('모임장 승인 트랜잭션(모임 갱신 + 단톡방 생성 + 신청 승인) 허용 [meetup_application_service.dart:95]', async () => {
        const db = as(ALICE);
        await assertSucceeds(
          runTransaction(db, async (tx) => {
            await tx.get(doc(db, 'meetups/m1'));
            await tx.get(doc(db, `meetups/m1/applications/${BOB}`));
            tx.update(doc(db, 'meetups/m1'), {
              occupiedSeats: 2, participantIds: arrayUnion(BOB), members: arrayUnion(BOB),
            });
            tx.set(doc(db, 'chatRooms/m1'), {
              id: 'm1', meetupId: 'm1', hostUid: ALICE, isGroup: true, members: 2,
              lastMessage: '합류했어요', participants: arrayUnion(ALICE, BOB), updatedAt: serverTimestamp(),
            }, { merge: true });
            tx.update(doc(db, `meetups/m1/applications/${BOB}`), { status: 'approved', reviewedAt: serverTimestamp() });
          }),
        );
      });

      test('신청자 스스로 승인 거부, 모임장이 partySize 변경 거부', async () => {
        await assertFails(updateDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`), { status: 'approved' }));
        await assertFails(
          updateDoc(doc(as(ALICE), `meetups/m1/applications/${BOB}`), { status: 'approved', partySize: 2 }),
        );
      });

      test('거절된 신청자는 같은 모임에 다시 신청할 수 없다 (현재 동작 기록)', async () => {
        await seed((db) => updateDoc(doc(db, `meetups/m1/applications/${BOB}`), { status: 'rejected' }));
        await assertFails(setDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`), application(BOB)));
      });

      test('신청자가 신청을 취소(삭제)할 수 없다 (현재 동작 기록: 삭제는 관리자 전용)', async () => {
        await assertFails(deleteDoc(doc(as(BOB), `meetups/m1/applications/${BOB}`)));
      });
    });
  });
});

// ---------------------------------------------------------------------------
describe('5. chatRooms / messages (체크리스트 8번)', () => {
  beforeEach(() =>
    seed(async (db) => {
      await setDoc(doc(db, 'chatRooms/r1'), {
        hostUid: ALICE, participants: [ALICE, BOB], isGroup: true, title: '보드게임', lastMessage: '',
      });
      await setDoc(doc(db, 'chatRooms/r1/messages/poll1'), {
        type: 'poll', senderId: ALICE, question: '몇 시?', voters: {},
      });
    }));

  test('참여자 get 허용, 비참여자·비로그인 get 거부', async () => {
    await assertSucceeds(getDoc(doc(as(BOB), 'chatRooms/r1')));
    await assertFails(getDoc(doc(as(CAROL), 'chatRooms/r1')));
    await assertFails(getDoc(doc(anon(), 'chatRooms/r1')));
  });

  test('participants arrayContains 목록 조회 허용, 필터 없는 목록 조회 거부', async () => {
    await assertSucceeds(
      getDocs(query(collection(as(BOB), 'chatRooms'), where('participants', 'array-contains', BOB))),
    );
    await assertFails(getDocs(collection(as(BOB), 'chatRooms')));
  });

  test('참여자 메시지 전송 트랜잭션 허용 [chat_repository.dart:165]', async () => {
    const db = as(BOB);
    await assertSucceeds(
      runTransaction(db, async (tx) => {
        await tx.get(doc(db, 'chatRooms/r1'));
        tx.set(doc(db, 'chatRooms/r1/messages/m1'), { type: 'text', text: '안녕', senderId: BOB, timestamp: serverTimestamp() });
        tx.update(doc(db, 'chatRooms/r1'), { lastMessage: '안녕', updatedAt: serverTimestamp() });
      }),
    );
  });

  test('비참여자 메시지 쓰기·읽기 거부, 보낸 사람 위조 거부', async () => {
    await assertFails(setDoc(doc(as(CAROL), 'chatRooms/r1/messages/x'), { text: 'x', senderId: CAROL }));
    await assertFails(getDoc(doc(as(CAROL), 'chatRooms/r1/messages/poll1')));
    await assertFails(setDoc(doc(as(BOB), 'chatRooms/r1/messages/y'), { text: 'x', senderId: ALICE }));
  });

  test(
    'userId 만 본인으로 두고 senderId 를 남으로 넣은 메시지는 거부되어야 한다',
    async () => {
      await assertFails(setDoc(doc(as(BOB), 'chatRooms/r1/messages/z'), { text: '사칭', senderId: ALICE, userId: BOB }));
    },
  );

  test('참여자 나가기(본인 제거 + leftUserIds) 허용 [chat_repository.dart:223]', async () => {
    await assertSucceeds(
      updateDoc(doc(as(BOB), 'chatRooms/r1'), { participants: arrayRemove(BOB), leftUserIds: arrayUnion(BOB) }),
    );
  });

  test('일반 참여자가 다른 사람을 내보내거나 제목을 바꾸는 것은 거부', async () => {
    await assertFails(updateDoc(doc(as(BOB), 'chatRooms/r1'), { participants: [BOB] }));
    await assertFails(updateDoc(doc(as(BOB), 'chatRooms/r1'), { title: '변경' }));
  });

  test('모임장은 단톡방 정보 수정 허용', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'chatRooms/r1'), { title: '변경' }));
  });

  test('보낸 사람은 자기 투표 메시지 수정 허용', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'chatRooms/r1/messages/poll1'), { voters: { [ALICE]: 0 } }));
  });

  test(
    '다른 참여자도 투표·일정 카드에 응답할 수 있어야 한다 [chat_system_cards.dart:550 → chat_repository.dart:206]',
    async () => {
      await assertSucceeds(updateDoc(doc(as(BOB), 'chatRooms/r1/messages/poll1'), { voters: { [BOB]: 1 } }));
    },
  );
});

// ---------------------------------------------------------------------------
describe('6. notifications / reports / inquiries / 공개 컬렉션', () => {
  test('본인 알림 목록(userId 필터) 조회 허용, 필터 없는 조회 거부 [notification_screen.dart:35]', async () => {
    await seed((db) => setDoc(doc(db, 'notifications/n1'), { userId: BOB, read: false }));
    await assertSucceeds(getDocs(query(collection(as(BOB), 'notifications'), where('userId', '==', BOB))));
    await assertFails(getDocs(collection(as(BOB), 'notifications')));
    await assertFails(getDoc(doc(as(CAROL), 'notifications/n1')));
  });

  test('본인 알림 읽음 처리 허용, 남의 알림 읽음 처리 거부 [notification_screen.dart:77]', async () => {
    await seed((db) => setDoc(doc(db, 'notifications/n1'), { userId: BOB, read: false }));
    await assertFails(updateDoc(doc(as(CAROL), 'notifications/n1'), { read: true }));
    await assertSucceeds(updateDoc(doc(as(BOB), 'notifications/n1'), { read: true }));
  });

  describe('모임 알림 (신청 → 모임장, 결정 → 신청자)', () => {
    beforeEach(() =>
      seed(async (db) => {
        await setDoc(doc(db, 'meetups/m1'), { hostUid: ALICE, title: '보드게임' });
        await setDoc(doc(db, `meetups/m1/applications/${BOB}`), { userId: BOB, status: 'pending', partySize: 1 });
      }));

    test('신청자가 모임장에게 신청 알림 생성 허용 [meetup_application_service.dart:71]', async () => {
      await assertSucceeds(
        addDoc(collection(as(BOB), 'notifications'), {
          userId: ALICE, type: 'meetup_request', title: '새로운 모임 참여 신청이 도착했어요',
          body: '[보드게임] 모임에 참여 신청이 들어왔어요.', meetupId: 'm1', read: false, createdAt: serverTimestamp(),
        }),
      );
    });

    test('모임장이 신청자에게 결정 알림 생성 허용 [meetup_application_service.dart:155]', async () => {
      await assertSucceeds(
        addDoc(collection(as(ALICE), 'notifications'), {
          userId: BOB, type: 'meetup_decision', title: '모임 신청이 승인됐어요',
          body: '모임 참여가 승인되었어요!', meetupId: 'm1', read: false, createdAt: serverTimestamp(),
        }),
      );
    });
  });

  test(
    '아무 내용의 알림을 남에게 보낼 수는 없어야 한다',
    async () => {
      await assertFails(
        addDoc(collection(as(BOB), 'notifications'), {
          userId: ALICE, type: 'system', title: '[운영팀] 계정 확인이 필요해요', body: '외부 링크', read: false,
        }),
      );
    },
  );

  test('신고 접수 허용 [global_data.dart:706], 비로그인 신고 거부', async () => {
    await assertSucceeds(addDoc(collection(as(BOB), 'reports'), {
      targetType: 'user', targetId: CAROL, targetUser: '캐롤', reporterUser: '밥', reason: '욕설', detail: '',
      status: 'pending_review', createdAt: serverTimestamp(),
    }));
    await assertFails(addDoc(collection(anon(), 'reports'), { reason: 'x' }));
  });

  test(
    '다른 사람이 낸 신고 내용을 읽을 수 없어야 한다',
    async () => {
      await seed((db) => setDoc(doc(db, 'reports/r1'), { targetId: CAROL, targetUser: '캐롤', reporterUser: '밥', reason: '욕설' }));
      await assertFails(getDoc(doc(as(CAROL), 'reports/r1')));
    },
  );

  test('문의: 본인 작성·조회 허용, 타인 조회 거부', async () => {
    await assertSucceeds(setDoc(doc(as(BOB), 'inquiries/q1'), { userId: BOB, text: '문의' }));
    await assertSucceeds(getDoc(doc(as(BOB), 'inquiries/q1')));
    await assertFails(getDoc(doc(as(CAROL), 'inquiries/q1')));
  });

  for (const c of ['bots', 'trend_events', 'notices']) {
    test(`${c}: 비로그인 읽기 허용, 일반 사용자 쓰기 거부, 관리자 쓰기 허용`, async () => {
      await seed((db) => setDoc(doc(db, `${c}/x`), { a: 1 }));
      await assertSucceeds(getDoc(doc(anon(), `${c}/x`)));
      await assertFails(setDoc(doc(as(BOB), `${c}/y`), { a: 1 }));
      await assertSucceeds(setDoc(doc(asAdmin(), `${c}/y`), { a: 1 }));
    });
  }
});
