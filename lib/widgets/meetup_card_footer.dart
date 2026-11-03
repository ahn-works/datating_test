import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/oomu_ui_helpers.dart';

/// A consistent baseline for identity and attendance, with a stacked alternative
/// when text scaling leaves too little room for both.
class MeetupCardFooter extends StatelessWidget {
  final Map<String, dynamic> meetup;
  const MeetupCardFooter({super.key, required this.meetup});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final manner = OomuUiHelpers.parseMannerTemp(meetup);
        final avatar = meetup['hostAvatar']?.toString() ?? '';
        final identity = Row(children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: OomuUiHelpers.surfaceMuted,
              backgroundImage: avatar.isEmpty ? null : appImg(avatar),
              child: avatar.isEmpty
                  ? const Icon(Icons.person_outline, size: 18)
                  : null),
          const SizedBox(width: 8),
          Expanded(
              child: Text((meetup['host'] ?? '모임 호스트').toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: OomuUiHelpers.textPrimary))),
        ]);
        final members = meetup['members']?.toString();
        final attendance = Text(
            members == null ? '참여 인원 확인 필요' : '$members명 참여',
            style: const TextStyle(
                fontSize: 13, color: OomuUiHelpers.textSecondary));
        final temperature = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: manner == null
                ? OomuUiHelpers.surfaceMuted
                : const Color(0xFFFFF0F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(OomuUiHelpers.formatMannerTemp(manner),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: manner == null
                      ? OomuUiHelpers.textSecondary
                      : const Color(0xFFC83243))),
        );
        if (constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(13) > 16) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: 8),
                Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [temperature, attendance]),
              ]);
        }
        return Column(children: [
          Row(children: [
            Expanded(child: identity),
            const SizedBox(width: 12),
            attendance
          ]),
          const SizedBox(height: 4),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: temperature)),
        ]);
      });
}
