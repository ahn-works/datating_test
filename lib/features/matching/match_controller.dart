// 스팟10의 가장 핵심인 "탐색 -> 대화 -> 만남 -> 결제" 상태를 촘촘하게 관리하는 컨트롤러

enum MatchStatus { 
  exploring,            // 1. 주변 탐색 중
  waitingAccept,        // 2. 10분 대화 신청 후 수락 대기 중
  chatting10Min,        // 3. 수락됨: 10분 익명 채팅 진행 중
  middleSpotSuggested,  // 4. 중간지점 카페 제안됨
  depositPaid,          // 5. 양측 1만원 보증금 결제 완료 (만남 확정)
  metAndCheckedIn       // 6. 현장 도착 후 QR 체크인 완료 (환불 처리)
}

class MatchController {
  MatchStatus _status = MatchStatus.exploring;
  MatchStatus get status => _status;

  // 1. 10분 대화 신청 로직
  void request10MinChat(String targetUserId) {
    _status = MatchStatus.waitingAccept;
    // TODO: 타겟 유저에게 푸시 알림 전송 및 소켓 이벤트 발송
  }

  // 2. 10분 채팅 시작 로직
  void startChat() {
    _status = MatchStatus.chatting10Min;
    // TODO: 10분 타이머 타이머 기동 (Timer.periodic) 및 웹소켓 룸 조인
  }

  // 3. GPS 기반 중간지점 추천 로직 (데이터 흐름)
  void suggestMiddleSpot(double myLat, double myLng, double partnerLat, double partnerLng) {
    _status = MatchStatus.middleSpotSuggested;
    // TODO: 두 좌표의 중앙값을 구한 뒤, 반경 1km 이내의 제휴 카페 목록 API 호출
  }

  // 4. 보증금 결제 로직
  void payNoShowDeposit(int amount) {
    // TODO: PG사(토스/카카오페이) 결제 모듈 호출
    // 결제 성공 시 DB 업데이트
    _status = MatchStatus.depositPaid;
  }

  // 5. QR 체크인 및 환불 로직
  void checkInWithQR(String qrCodeData) {
    // TODO: 서버에 QR 코드 유효성 검증
    // 성공 시 보증금 환불(취소) API 호출 및 매너 평가 화면으로 전환
    _status = MatchStatus.metAndCheckedIn;
  }
}
