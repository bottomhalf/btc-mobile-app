import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/quick_meetings.dart';
import '../../../theme/app_theme.dart';
import '../meet_controller.dart';

/// Displays recent meetings fetched from the API as a
/// grid of glassmorphism cards with distinct tags for Scheduled vs Quick meetings.
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

      final meetings = controller.displayedMeetings;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Chips ──
          _buildFilterChips(context),
          const SizedBox(height: 14),

          // ── Empty state ──
          if (meetings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      controller.selectedFilter.value == 1
                          ? Icons.event_busy_rounded
                          : Icons.videocam_off_rounded,
                      size: 42,
                      color: AppTheme.textSecondary(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.selectedFilter.value == 1
                          ? 'No scheduled meetings found'
                          : controller.selectedFilter.value == 2
                              ? 'No quick meetings found'
                              : 'No meetings found',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ── Grid of meeting cards ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: meetings.length,
              itemBuilder: (context, index) => _MeetingCard(meeting: meetings[index]),
            ),
        ],
      );
    });
  }

  Widget _buildFilterChips(BuildContext context) {
    final allCount = controller.allMeetings.length;
    final scheduledCount = controller.scheduledMeetings.length;
    final quickCount = controller.quickMeetings.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _filterChip(
            context,
            label: 'All',
            count: allCount,
            isSelected: controller.selectedFilter.value == 0,
            onTap: () => controller.selectedFilter.value = 0,
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: 'Scheduled',
            count: scheduledCount,
            icon: Icons.calendar_today_rounded,
            chipColor: const Color(0xFF6C5CE7),
            isSelected: controller.selectedFilter.value == 1,
            onTap: () => controller.selectedFilter.value = 1,
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: 'Quick Meet',
            count: quickCount,
            icon: Icons.bolt_rounded,
            chipColor: const Color(0xFF00B894),
            isSelected: controller.selectedFilter.value == 2,
            onTap: () => controller.selectedFilter.value = 2,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required int count,
    IconData? icon,
    Color? chipColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = chipColor ?? AppTheme.accentPurple;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : AppTheme.card(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.divider(context),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? activeColor : AppTheme.textSecondary(context),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.25)
                    : AppTheme.cardAlt(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : AppTheme.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final isScheduled = meeting.isScheduled;

    return GestureDetector(
      onTap: () => controller.openMeeting(meeting),
      onLongPress: () => _showMeetingDetailsSheet(context, meeting),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.card(context).withValues(alpha: 0.92),
                  AppTheme.cardAlt(context).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isScheduled
                    ? const Color(0xFF6C5CE7).withValues(alpha: 0.35)
                    : colorPair[0].withValues(alpha: 0.25),
                width: isScheduled ? 1.2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row: Tag + Password ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scheduled / Quick Meet Tag
                    Flexible(child: _buildTag(isScheduled)),
                    if (meeting.meetingPassword.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.key_rounded, size: 9, color: Colors.amber),
                              const SizedBox(width: 2.5),
                              Flexible(
                                child: Text(
                                  meeting.meetingPassword,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // ── Title ──
                Text(
                  meeting.title.isNotEmpty
                      ? meeting.title
                      : (isScheduled ? 'Scheduled Meeting' : 'Quick Meeting'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppTheme.textPrimary(context),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // ── Organizer ──
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 11,
                      color: AppTheme.textSecondary(context),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        meeting.organizerName.isNotEmpty ? meeting.organizerName : 'Unknown Host',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Middle Section: Rich Details (Scheduled vs Quick) ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isScheduled) ...[
                        // Scheduled details container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.cardAlt(context).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.divider(context).withValues(alpha: 0.5),
                              width: 0.7,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              if (meeting.timeRangeLabel.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 10,
                                      color: Color(0xFF8E7CF3),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        meeting.timeRangeLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                              ],
                              // Date
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 9.5,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _formatDate(meeting.startDate),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: AppTheme.textSecondary(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Participants count if any
                              if (meeting.totalParticipants > 0) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_outline_rounded,
                                      size: 10,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${meeting.totalParticipants} attendee${meeting.totalParticipants > 1 ? 's' : ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        // Quick meeting info container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.cardAlt(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 10,
                                    color: Color(0xFF00B894),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Instant Room',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 9.5,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(meeting.startDate),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ── Bottom Row: Duration + Info + Join Pill ──
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: AppTheme.textSecondary(context),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        _formatDuration(meeting.durationInSecond),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showMeetingDetailsSheet(context, meeting),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.cardAlt(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isScheduled
                              ? const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)]
                              : const [Color(0xFF00B894), Color(0xFF55EFC4)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (isScheduled ? const Color(0xFF6C5CE7) : const Color(0xFF00B894))
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.videocam_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Join',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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

  Widget _buildTag(bool isScheduled) {
    if (isScheduled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.calendar_month_rounded,
              size: 9.5,
              color: Color(0xFF8E7CF3),
            ),
            SizedBox(width: 3),
            Text(
              'Scheduled',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8E7CF3),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF00B894).withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.bolt_rounded,
            size: 10,
            color: Color(0xFF00B894),
          ),
          SizedBox(width: 2.5),
          Text(
            'Quick Meet',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00B894),
              letterSpacing: 0.2,
            ),
          ),
        ],
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

  void _showMeetingDetailsSheet(BuildContext context, QuickMeetings meeting) {
    final controller = Get.find<MeetController>();
    final isScheduled = meeting.isScheduled;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppTheme.card(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.divider(ctx)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header: Tag + Title
            Row(
              children: [
                _buildTag(isScheduled),
                const Spacer(),
                if (meeting.meetingPassword.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.key_rounded, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          meeting.meetingPassword,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: meeting.meetingPassword));
                            Get.snackbar(
                              'Copied',
                              'Password copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 12, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              meeting.title.isNotEmpty ? meeting.title : 'Meeting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(ctx),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organized by: ${meeting.organizerName.isNotEmpty ? meeting.organizerName : "Unknown"}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(ctx),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Detail rows
            if (isScheduled && meeting.timeRangeLabel.isNotEmpty)
              _detailRow(
                ctx,
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: meeting.timeRangeLabel,
              ),

            if (meeting.startDate != null)
              _detailRow(
                ctx,
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: '${meeting.startDate!.day}/${meeting.startDate!.month}/${meeting.startDate!.year}',
              ),

            _detailRow(
              ctx,
              icon: Icons.schedule_rounded,
              label: 'Duration',
              value: _formatDuration(meeting.durationInSecond),
            ),

            if (isScheduled && meeting.repeatType > 0)
              _detailRow(
                ctx,
                icon: Icons.repeat_rounded,
                label: 'Repeats',
                value: meeting.repeatTypeLabel,
              ),

            if (meeting.totalParticipants > 0)
              _detailRow(
                ctx,
                icon: Icons.people_outline_rounded,
                label: 'Participants',
                value: '${meeting.totalParticipants} attendee(s)',
              ),

            if (meeting.agenda != null && meeting.agenda!.trim().isNotEmpty)
              _detailRow(
                ctx,
                icon: Icons.notes_rounded,
                label: 'Agenda',
                value: meeting.agenda!.trim(),
              ),

            if (meeting.meetingId.isNotEmpty)
              _detailRow(
                ctx,
                icon: Icons.tag_rounded,
                label: 'Meeting ID',
                value: meeting.meetingId,
                canCopy: true,
              ),

            const SizedBox(height: 20),

            // Big Join Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.openMeeting(meeting);
                },
                icon: const Icon(Icons.videocam_rounded, color: Colors.white),
                label: const Text(
                  'Join Meeting Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.accentPurple),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ),
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  'Copied',
                  '$label copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppTheme.accentPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

