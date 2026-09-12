import 'package:flutter/material.dart';

/// Companion side rail / panel on the right side matching team.png.
///
/// Features:
/// - Narrow 52px vertical strip on the far right edge of the desktop window
/// - Clean icons:
///   1. Calendar (White card with blue header and date)
///   2. Keep (Amber card with lightbulb)
///   3. Voice / Call (Green circle with phone/chat icon)
///   4. Tasks (Blue circle with checkmark)
///   5. Add-ons (Geometric extension / puzzle icon)
///   6. Bottom "+" button to get add-ons
/// - Clickable icons that open a clean 310px companion utility sheet (Calendar, Keep, Tasks, etc.)
class DesktopRightSidePanel extends StatefulWidget {
  const DesktopRightSidePanel({super.key});

  @override
  State<DesktopRightSidePanel> createState() => _DesktopRightSidePanelState();
}

enum _PanelTab { calendar, keep, voice, tasks, addons }

class _DesktopRightSidePanelState extends State<DesktopRightSidePanel> {
  _PanelTab? _activeTab;

  void _onTabSelected(_PanelTab tab) {
    setState(() {
      if (_activeTab == tab) {
        _activeTab = null; // Toggle close if already active
      } else {
        _activeTab = tab;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Expandable Side Sheet when a tool is clicked ──
        if (_activeTab != null) ...[
          Container(
            width: 310,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: _buildPanelContent(),
          ),
        ],

        // ── Rightmost Vertical Rail (52px) matching team.png ──
        Container(
          width: 52,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),

              // 1. Calendar
              _buildRailButton(
                tab: _PanelTab.calendar,
                tooltip: 'Calendar',
                child: _buildCalendarIcon(),
              ),
              const SizedBox(height: 14),

              // 2. Keep / Notes
              _buildRailButton(
                tab: _PanelTab.keep,
                tooltip: 'Keep',
                child: _buildKeepIcon(),
              ),
              const SizedBox(height: 14),

              // 3. Voice / Phone
              _buildRailButton(
                tab: _PanelTab.voice,
                tooltip: 'Voice & Calls',
                child: _buildVoiceIcon(),
              ),
              const SizedBox(height: 14),

              // 4. Tasks
              _buildRailButton(
                tab: _PanelTab.tasks,
                tooltip: 'Tasks',
                child: _buildTasksIcon(),
              ),

              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  height: 20,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(height: 2),

              // 5. Add-ons
              _buildRailButton(
                tab: _PanelTab.addons,
                tooltip: 'Add-ons',
                child: const Icon(
                  Icons.extension_outlined,
                  size: 20,
                  color: Color(0xFF5F6368),
                ),
              ),

              const Spacer(),

              // Bottom: Get Add-ons (+)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Tooltip(
                  message: 'Get add-ons',
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 22,
                      color: Color(0xFF5F6368),
                    ),
                    onPressed: () {
                      _onTabSelected(_PanelTab.addons);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRailButton({
    required _PanelTab tab,
    required String tooltip,
    required Widget child,
  }) {
    final isSelected = _activeTab == tab;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => _onTabSelected(tab),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE0E7FF).withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // Google Calendar style icon with '31'
  Widget _buildCalendarIcon() {
    final day = DateTime.now().day.toString();

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A73E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF1A73E8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A73E8),
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Google Keep icon (amber with lightbulb)
  Widget _buildKeepIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF9AB00),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF9AB00).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.lightbulb_outline_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  // Voice / Phone icon (green circle)
  Widget _buildVoiceIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.call_rounded,
        color: Colors.white,
        size: 15,
      ),
    );
  }

  // Google Tasks icon (blue circle with checkmark)
  Widget _buildTasksIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 17,
      ),
    );
  }

  // Content for open panel
  Widget _buildPanelContent() {
    switch (_activeTab) {
      case _PanelTab.calendar:
        return _buildCalendarSheet();
      case _PanelTab.keep:
        return _buildKeepSheet();
      case _PanelTab.voice:
        return _buildVoiceSheet();
      case _PanelTab.tasks:
        return _buildTasksSheet();
      case _PanelTab.addons:
      default:
        return _buildAddonsSheet();
    }
  }

  Widget _buildSheetHeader(String title, IconData icon, Color color) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6B7280)),
              onPressed: () {
                setState(() {
                  _activeTab = null;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSheet() {
    final now = DateTime.now();
    return Column(
      children: [
        _buildSheetHeader('Calendar', Icons.calendar_month_rounded, const Color(0xFF1A73E8)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Today, ${now.month}/${now.day}/${now.year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 12),
              _buildEventCard(
                title: 'Daily Stand-Up Meeting',
                time: '10:00 AM - 10:30 AM',
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 8),
              _buildEventCard(
                title: 'Sprint Planning',
                time: '2:00 PM - 3:00 PM',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 8),
              _buildEventCard(
                title: 'Team Sync & Wrap-up',
                time: '5:30 PM - 6:00 PM',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeepSheet() {
    return Column(
      children: [
        _buildSheetHeader('Keep Notes', Icons.lightbulb_outline_rounded, const Color(0xFFF9AB00)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Take a note...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                    Spacer(),
                    Icon(Icons.check_box_outlined, size: 18, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildNoteCard(
                title: 'Hostinger credentials',
                content: 'thirtyplusmatrimonials@gmail.com\nPlusmat@123',
              ),
              const SizedBox(height: 8),
              _buildNoteCard(
                title: 'Sprint notes',
                content: 'Focus on desktop widgets & Google Chat layout alignment.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF78350F),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSheet() {
    return Column(
      children: [
        _buildSheetHeader('Voice & Calls', Icons.call_rounded, const Color(0xFF22C55E)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Text(
                'Recent Calls',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.call_made_rounded, color: Color(0xFF16A34A), size: 18),
                ),
                title: Text('Marghubur Rahman', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Incoming • Today 2:56 PM', style: TextStyle(fontSize: 11.5)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFFEE2E2),
                  child: Icon(Icons.call_missed_rounded, color: Color(0xFFDC2626), size: 18),
                ),
                title: Text('vivek kumar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Missed • Yesterday 9:29 PM', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSheet() {
    return Column(
      children: [
        _buildSheetHeader('Tasks', Icons.check_circle_outline_rounded, const Color(0xFF1A73E8)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add a task', style: TextStyle(fontSize: 12.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A73E8),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 14),
              _buildTaskItem('Verify Google Chat UI alignment', true),
              _buildTaskItem('Check desktop right panel & scrollbar', true),
              _buildTaskItem('Deploy release build to testers', false),
              _buildTaskItem('Prepare meeting notes for stand-up', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isDone ? const Color(0xFF1A73E8) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                color: isDone ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsSheet() {
    return Column(
      children: [
        _buildSheetHeader('Google Workspace Marketplace', Icons.extension_outlined, const Color(0xFF5F6368)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Available Add-ons',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 12),
              _buildAddonCard('Zoom for Google Workspace', 'Video meetings integration', Icons.videocam),
              const SizedBox(height: 8),
              _buildAddonCard('Asana', 'Task and project tracking', Icons.assignment_outlined),
              const SizedBox(height: 8),
              _buildAddonCard('Lucidchart Diagrams', 'Create visual flowcharts', Icons.schema_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddonCard(String name, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Icon(icon, size: 16, color: const Color(0xFF374151)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
