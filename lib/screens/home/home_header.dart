import 'package:flutter/material.dart';

import '../../ui/oomu_tokens.dart';
import '../../widgets/bouncy_tap.dart';
import '../explore_map_screen.dart';
import '../filter_screen.dart';
import '../notification_screen.dart';

/// 홈 화면 상단 앱바 컴포넌트
class HomeHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentLocation;
  final VoidCallback onLocationTap;
  final ValueChanged<int>? onNotificationTabSelected;

  const HomeHeaderAppBar({
    super.key,
    required this.currentLocation,
    required this.onLocationTap,
    this.onNotificationTabSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: OomuTokens.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: OomuTokens.spacingLg,
      title: BouncyTap(
        scaleDown: 0.96,
        onTap: onLocationTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OomuTokens.touchTargetMin),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentLocation,
                  style: const TextStyle(
                    fontWeight: OomuTokens.weightBold,
                    fontSize: OomuTokens.fs20,
                    color: OomuTokens.textPrimary,
                    fontFamily: OomuTokens.fontFamily,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: OomuTokens.spacingXs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: OomuTokens.textPrimary,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Semantics(
          button: true,
          label: '검색',
          child: BouncyTap(
            scaleDown: 0.92,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: OomuTokens.touchTargetMin,
              ),
              child: const Center(
                child: Icon(
                  Icons.search_rounded,
                  color: OomuTokens.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Semantics(
            button: true,
            label: '알림',
            child: BouncyTap(
              scaleDown: 0.92,
              onTap: () async {
                final tab = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
                if (tab != null && onNotificationTabSelected != null) {
                  onNotificationTabSelected!(tab);
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: OomuTokens.touchTargetMin,
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: OomuTokens.textPrimary,
                        size: 24,
                      ),
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: OomuTokens.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
