import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Top bar with live meeting indicator and participant count badge.
class MeetingTopBar extends StatelessWidget {
  final int participantCount;
  final VoidCallback onTapParticipants;

  const MeetingTopBar({
    super.key,
    required this.participantCount,
    required this.onTapParticipants,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fiber_manual_record_rounded,
              color: AppTheme.successGreen,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'In Meeting',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTapParticipants,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.divider(context).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: AppTheme.accentPurple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$participantCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
