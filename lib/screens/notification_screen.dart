import 'package:flutter/material.dart';

import '../ui/oomu_tokens.dart';

/// 알림을 전달하는 서버 경로가 연결되기 전에는 임의의 알림이나 빈 필터를 노출하지 않는다.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: OomuTokens.bgCanvas,
        appBar: AppBar(
          backgroundColor: OomuTokens.surface,
          surfaceTintColor: OomuTokens.surface,
          title: Text('알림',
              style: TextStyle(
                  color: OomuTokens.textPrimary,
                  fontSize: OomuTokens.fs18,
                  fontWeight: FontWeight.w700)),
          leading: IconButton(
            tooltip: '뒤로가기',
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_none_rounded,
                          size: 30, color: OomuTokens.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Text('알림 연결을 준비하고 있어요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: OomuTokens.textPrimary,
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.w700,
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Text('현재는 새 알림이 표시되지 않아요.\n동네 모임은 홈에서 계속 둘러볼 수 있어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: OomuTokens.textSecondary,
                            fontSize: OomuTokens.fs14,
                            height: 1.5)),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, 0),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(160, 48),
                        foregroundColor: OomuTokens.textPrimary,
                        side: BorderSide(
                            color: OomuTokens.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12)),
                      ),
                      child: const Text('동네 모임 둘러보기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
