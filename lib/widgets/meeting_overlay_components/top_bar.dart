import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

    return Obx(() {
      if (!service.isControlsVisible.value) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
            Expanded(
              child: Text(
                service.meetingName.isNotEmpty
                    ? service.meetingName
                    : 'In Meeting',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ),
            // Minimize button
            GestureDetector(
              onTap: service.minimize,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.divider(context).withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Icons.picture_in_picture_alt_rounded,
                  size: 20,
                  color: AppTheme.accentPurple,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    '${service.participantCount.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
