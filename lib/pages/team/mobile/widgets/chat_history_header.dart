import 'package:conference/models/conversation.dart';
import 'package:conference/models/participant.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Card showing conversation metadata at the beginning/top of the chat history.
class ChatHistoryHeader extends StatelessWidget {
  final Conversation convo;
  final bool isEmptyState;

  const ChatHistoryHeader({
    super.key,
    required this.convo,
    this.isEmptyState = false,
  });

  @override
  Widget build(BuildContext context) {
    Participant? admin;
    for (var m in convo.members) {
      if (m.role.toLowerCase() == 'admin' || m.role.toLowerCase() == 'creator') {
        admin = m;
        break;
      }
    }
    if (admin == null && convo.members.isNotEmpty) {
      admin = convo.members.first;
    }
    final creatorName = convo.createdBy != null && convo.createdBy!.isNotEmpty
        ? convo.createdBy!
        : (admin != null ? admin.firstName : 'the team');

    final createdDate = convo.createdAt ?? convo.lastMessageAt ?? DateTime.now();
    final formattedDate = '${createdDate.day} ${_getMonthName(createdDate.month)} ${createdDate.year}';
    final formattedTime = '${createdDate.hour.toString().padLeft(2, '0')}:${createdDate.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentPurple, const Color(0xFF8E7CF3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: convo.title.isNotEmpty
                    ? Text(
                        convo.title[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(
                        Icons.forum_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            convo.title.isNotEmpty ? convo.title : 'Conversation Info',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              convo.type.toUpperCase(),
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Created on',
            value: '$formattedDate at $formattedTime',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.person_outline_rounded,
            label: 'Created by',
            value: creatorName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.people_outline_rounded,
            label: 'Members',
            value: '${convo.memberCount} participants',
          ),
          if (convo.members.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(
                    convo.members.length > 5 ? 5 : convo.members.length,
                    (index) {
                      final member = convo.members[index];
                      final total = convo.members.length > 5 ? 5 : convo.members.length;
                      final offset = (index - (total - 1) / 2.0) * 20.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.card(context),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.primaries[member.userId.hashCode.abs() % Colors.primaries.length].withValues(alpha: 0.8),
                            backgroundImage: member.avatar != null && member.avatar!.isNotEmpty
                                ? NetworkImage(member.avatar!)
                                : null,
                            child: member.avatar == null || member.avatar!.isEmpty
                                ? Text(
                                    member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  if (convo.members.length > 5)
                    Transform.translate(
                      offset: Offset(((5 - 1) / 2.0 * 20.0) + 22.0, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.card(context), width: 1.5),
                        ),
                        child: Text(
                          '+${convo.members.length - 5}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary(context),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
}
