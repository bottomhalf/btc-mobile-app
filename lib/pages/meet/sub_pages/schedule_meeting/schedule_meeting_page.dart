import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../theme/app_theme.dart';
import 'schedule_meeting_controller.dart';

class ScheduleMeetingPage extends GetView<ScheduleMeetingController> {
  const ScheduleMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Schedule Meeting',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      body: Obx(() {
        final meeting = controller.scheduledMeeting.value;

        // If meeting scheduled successfully, display the summary view
        if (meeting != null) {
          return _buildSuccessView(context, meeting);
        }

        return _buildFormView(context);
      }),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildScheduleHeader(context),
          // Title field
          Text(
            'Meeting Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.titleController,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'e.g. Daily Standup',
              prefixIcon: Icon(Icons.title_rounded, color: AppTheme.accentPurple),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a meeting title';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // All Day Switch
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.today_rounded, size: 20, color: AppTheme.accentPurple),
                    const SizedBox(width: 12),
                    Text(
                      'All-day Event',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: controller.isAllDay.value,
                  activeTrackColor: AppTheme.accentPurple,
                  activeThumbColor: Colors.white,
                  onChanged: controller.toggleAllDay,
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),

          // Starts Row (Date & Time)
          Text(
            'Starts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectStartDate(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardAlt(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.divider(context).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final date = controller.selectedStartDate.value;
                            return Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary(context),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.isAllDay.value) return const SizedBox.shrink();
                return Row(
                  children: [
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => controller.selectStartTime(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardAlt(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.divider(context).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 18, color: AppTheme.accentPurple),
                            const SizedBox(width: 8),
                            Text(
                              controller.selectedStartTime.value.format(context),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Ends Row (Date & Time)
          Text(
            'Ends',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectEndDate(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardAlt(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.divider(context).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final date = controller.selectedEndDate.value;
                            return Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary(context),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.isAllDay.value) return const SizedBox.shrink();
                return Row(
                  children: [
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => controller.selectEndTime(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardAlt(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.divider(context).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 18, color: AppTheme.accentPurple),
                            const SizedBox(width: 8),
                            Text(
                              controller.selectedEndTime.value.format(context),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Repeat dropdown
          Text(
            'Repeat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: controller.repeatType.value,
            dropdownColor: AppTheme.card(context),
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.repeat_rounded, color: AppTheme.accentPurple),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Does not repeat', overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 1, child: Text('Daily', overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 2, child: Text('Weekly', overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 3, child: Text('Monthly', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) {
              if (val != null) controller.repeatType.value = val;
            },
          )),
          const SizedBox(height: 20),

          // Duration dropdown
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: [900, 1800, 2700, 3600, 7200, 10800].contains(controller.durationInSecond.value)
                ? controller.durationInSecond.value
                : 3600,
            dropdownColor: AppTheme.card(context),
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.timer_rounded, color: AppTheme.accentPurple),
            ),
            items: const [
              DropdownMenuItem(value: 900, child: Text('15 minutes')),
              DropdownMenuItem(value: 1800, child: Text('30 minutes')),
              DropdownMenuItem(value: 2700, child: Text('45 minutes')),
              DropdownMenuItem(value: 3600, child: Text('1 hour')),
              DropdownMenuItem(value: 7200, child: Text('2 hours')),
              DropdownMenuItem(value: 10800, child: Text('3 hours')),
            ],
            onChanged: (val) {
              if (val != null) controller.setDuration(val);
            },
          )),
          const SizedBox(height: 20),

          // Meeting Password field with refresh/regenerate button
          Text(
            'Meeting Password',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.passwordController,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Security password',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.accentPurple),
              suffixIcon: IconButton(
                icon: Icon(Icons.refresh_rounded, color: AppTheme.accentPurple),
                onPressed: controller.generatePassword,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Agenda / Description
          Text(
            'Agenda (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.agendaController,
            maxLines: 3,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Describe meeting agenda...',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(Icons.description_outlined, color: AppTheme.accentPurple),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Participants
          _buildParticipantsSection(context),
          const SizedBox(height: 36),

          // Schedule Meeting Button
          Obx(() {
            final isLoading = controller.isLoading.value;
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => controller.saveMeeting(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Schedule Meeting',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, dynamic meeting) {
    final fullDate = meeting.startDate != null
        ? '${meeting.startDate!.day} ${_getMonthName(meeting.startDate!.month)} ${meeting.startDate!.year} at ${_formatTime(meeting.startDate!)}'
        : 'Scheduled';

    final shareText = '''
Join my scheduled meeting:
Topic: ${meeting.title}
Date & Time: $fullDate
Meeting ID: ${meeting.meetingId}
Password: ${meeting.meetingPassword}
''';

    return Center(
      child: ListView(
        padding: const EdgeInsets.all(24),
        shrinkWrap: true,
        children: [
          // Big Checkmark Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'Meeting Scheduled!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Your meeting detail is ready to share.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Detail Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildInfoRow(context, Icons.calendar_today_rounded, 'Date & Time', fullDate),
                const SizedBox(height: 14),
                _buildInfoRow(context, Icons.videocam_rounded, 'Meeting ID', meeting.meetingId),
                const SizedBox(height: 14),
                _buildInfoRow(context, Icons.lock_outline_rounded, 'Password', meeting.meetingPassword),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shareText));
                    Get.snackbar(
                      'Copied',
                      'Meeting invitation copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy Invitation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentPurple,
                    side: BorderSide(color: AppTheme.accentPurple),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.accentPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildScheduleHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPurple.withValues(alpha: 0.12),
            AppTheme.accentPurple.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule a Video Meeting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan your session, invite team members, and generate an instant join link.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final count = controller.selectedParticipants.length;
              return Row(
                children: [
                  Text(
                    'Participants',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
            TextButton.icon(
              onPressed: () => _openParticipantsPicker(context),
              icon: Icon(Icons.person_add_alt_1_rounded, size: 16, color: AppTheme.accentPurple),
              label: Text(
                'Add Invitees',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentPurple,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final participants = controller.selectedParticipants;
          if (participants.isEmpty) {
            return InkWell(
              onTap: () => _openParticipantsPicker(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardAlt(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.divider(context).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group_add_outlined, size: 20, color: AppTheme.accentPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Invite participants to this meeting (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppTheme.textSecondary(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.5),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: participants.map((p) {
                final name = '${p.firstName} ${p.lastName ?? ''}'.trim();
                final displayName = name.isNotEmpty ? name : p.email;
                return Chip(
                  backgroundColor: AppTheme.card(context),
                  side: BorderSide(
                    color: AppTheme.accentPurple.withValues(alpha: 0.3),
                  ),
                  avatar: AppAvatar(
                    name: displayName,
                    imageUrl: p.avatar,
                    size: 24,
                    fontSize: 10,
                  ),
                  label: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  deleteIconColor: AppTheme.textSecondary(context),
                  onDeleted: () => controller.removeParticipant(p.userId),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  void _openParticipantsPicker(BuildContext context) {
    final availableContacts = controller.getAvailableContacts();
    final searchQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Add Participants',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    onChanged: (val) => searchQuery.value = val,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'Search contacts...',
                      prefixIcon: Icon(Icons.search_rounded, color: AppTheme.accentPurple),
                      filled: true,
                      fillColor: AppTheme.cardAlt(context),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                // Contacts List
                Expanded(
                  child: Obx(() {
                    final query = searchQuery.value.trim().toLowerCase();
                    final filtered = availableContacts.where((p) {
                      final name = '${p.firstName} ${p.lastName ?? ''}'.toLowerCase();
                      final email = p.email.toLowerCase();
                      return name.contains(query) || email.contains(query);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          availableContacts.isEmpty
                              ? 'No contacts found'
                              : 'No matching contacts',
                          style: TextStyle(color: AppTheme.textSecondary(context)),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final participant = filtered[index];
                        final fullName = '${participant.firstName} ${participant.lastName ?? ''}'.trim();
                        final displayName = fullName.isNotEmpty ? fullName : participant.email;

                        return Obx(() {
                          final isSelected = controller.isParticipantSelected(participant.userId);
                          return ListTile(
                            leading: AppAvatar(
                              name: displayName,
                              imageUrl: participant.avatar,
                              size: 40,
                            ),
                            title: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            subtitle: participant.email.isNotEmpty
                                ? Text(
                                    participant.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  )
                                : null,
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: AppTheme.accentPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) => controller.toggleParticipant(participant),
                            ),
                            onTap: () => controller.toggleParticipant(participant),
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
