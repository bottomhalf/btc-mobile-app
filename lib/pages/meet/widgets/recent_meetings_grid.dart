import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/quick_meetings.dart';
import '../../../theme/app_theme.dart';
import '../meet_controller.dart';

/// Displays top 6 recent meetings fetched from the API as a
/// grid of glassmorphism cards.
class RecentMeetingsGrid extends GetView<MeetController> {
  const RecentMeetingsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoadingMeetings.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.accentPurple,
            ),
          ),
        );
      }

      // Error state
      if (controller.meetingsError.value != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppTheme.textSecondary(context),
              ),
              const SizedBox(height: 12),
              Text(
                'Couldn\'t load meetings',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: controller.fetchRecentMeetings,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentPurple,
                ),
              ),
            ],
          ),
        );
      }

      // Empty state
      if (controller.quickMeetings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  size: 40,
                  color: AppTheme.textSecondary(context),
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent meetings',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Meeting cards — grid of 2 columns
      final meetings = controller.quickMeetings;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: meetings.length,
        itemBuilder: (context, index) => _MeetingCard(meeting: meetings[index]),
      );
    });
  }
}

class _MeetingCard extends StatelessWidget {
  final QuickMeetings meeting;

  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeetController>();

    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
      const [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    ];
    final colorPair = gradients[meeting.meetingId.hashCode.abs() % gradients.length];

    return GestureDetector(
      onTap: () => controller.openMeeting(meeting),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.card(context).withValues(alpha: 0.9),
                  AppTheme.cardAlt(context).withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorPair[0].withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colorPair),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (meeting.meetingPassword.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.accentPurple.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.key_rounded,
                              size: 10,
                              color: AppTheme.accentPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meeting.meetingPassword,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  meeting.title.isNotEmpty ? meeting.title : 'Quick Meeting',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textPrimary(context),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'By: ${meeting.organizerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(meeting.durationInSecond),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(meeting.startDate),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0m';
    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      return minutes > 0 ? '${duration.inHours}h ${minutes}m' : '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
