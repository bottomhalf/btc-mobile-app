import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
          _buildComingSoonIllustration(context),
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

          // Date and Time Pickers Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => controller.selectDate(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                final date = controller.selectedDate.value;
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
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => controller.selectTime(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() {
                                final time = controller.selectedTime.value;
                                return Text(
                                  time.format(context),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Duration picker dropdown
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: controller.selectedDuration.value,
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
              if (val != null) controller.selectedDuration.value = val;
            },
          ),
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
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: null, // Disabled: Coming soon
              child: const Text(
                'Schedule Meeting (Coming Soon)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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

  Widget _buildComingSoonIllustration(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Graphic container
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 64,
                height: 64,
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
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.card(context), width: 2),
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Schedule Feature Underway',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is right now not available. We are currently integrating Calendars to let you sync scheduled events automatically! Very soon it will be going to come up.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
