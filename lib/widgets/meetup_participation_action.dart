import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/meetup_application_service.dart';
import '../utils/oomu_ui_helpers.dart';

class MeetupParticipationAction extends StatelessWidget {
  final Map<String, dynamic>? meetup;
  final VoidCallback? onApply;
  const MeetupParticipationAction(
      {super.key, required this.meetup, required this.onApply});

  Widget _button(String text, VoidCallback? action) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 52),
              backgroundColor: OomuUiHelpers.brandCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(text, textAlign: TextAlign.center)),
      );

  @override
  Widget build(BuildContext context) {
    final id = meetup?['id']?.toString() ?? '';
    if (Firebase.apps.isEmpty || id.isEmpty) return _button('참여 신청하기', onApply);
    if (!MeetupApplicationService.enabled) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('참여 신청 기능은 아직 열리지 않았어요.')),
          ),
          icon: const Icon(Icons.info_outline_rounded, size: 18),
          label: const Text('참여 신청 준비 중'),
          style: OutlinedButton.styleFrom(
            backgroundColor: OomuUiHelpers.surfaceMuted,
            foregroundColor: OomuUiHelpers.textSecondary,
            side: const BorderSide(color: OomuUiHelpers.borderNeutral),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _button('참여 신청하기', onApply);
    if (MeetupApplicationService.hostUid(meetup!) == uid) {
      return _button('참여 신청 관리', () => _review(context, id));
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('meetups')
          .doc(id)
          .collection('applications')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _button('신청 상태 확인 재시도', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('신청 상태를 불러오지 못했어요. 화면을 다시 열어 주세요.')));
          });
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _button('신청 상태 확인 중…', null);
        }
        switch (snapshot.data?.data()?['status']) {
          case 'pending':
            return _button('모임장 승인 대기 중', null);
          case 'approved':
            return _button('참여가 승인됐어요', null);
          case 'rejected':
            return _button('이번 신청은 승인되지 않았어요', null);
          default:
            return _button('참여 신청하기', onApply);
        }
      },
    );
  }

  void _review(BuildContext context, String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
          child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .7,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text('참여 신청 관리',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('meetups')
                .doc(id)
                .collection('applications')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                    child: Text('신청 목록을 불러오지 못했어요. 잠시 후 다시 열어 주세요.'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final requests = snapshot.data!.docs;
              if (requests.isEmpty) {
                return const Center(child: Text('대기 중인 신청이 없어요.'));
              }
              return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    Future<void> decide(bool approve) async {
                      try {
                        await MeetupApplicationService.decide(id, request.id,
                            approve: approve);
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      approve ? '신청을 승인했어요.' : '신청을 거절했어요.')));
                        }
                      } catch (e) {
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                  content: Text(e is StateError
                                      ? e.message.toString()
                                      : '처리하지 못했어요. 다시 시도해 주세요.')));
                        }
                      }
                    }

                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('${request.data()['partySize'] ?? 1}명 참여 신청',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(request
                                          .data()['message']
                                          ?.toString()
                                          .trim()
                                          .isNotEmpty ==
                                      true
                                  ? request.data()['message'].toString()
                                  : '인사말이 없는 신청이에요.'),
                              const SizedBox(height: 12),
                              Wrap(spacing: 12, children: [
                                OutlinedButton(
                                    onPressed: () => decide(false),
                                    child: const Text('거절')),
                                ElevatedButton(
                                    onPressed: () => decide(true),
                                    child: const Text('승인'))
                              ]),
                              const Divider(),
                            ]));
                  });
            },
          )),
        ]),
      )),
    );
  }
}
