import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../theme/app_theme.dart';
import 'participant_card.dart';

/// Dynamic layout grid for meeting participants.
class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;
  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback onShowAllParticipants;

  const ParticipantGrid({
    super.key,
    required this.participants,
    required this.isMicOn,
    required this.isCameraOn,
    required this.onShowAllParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final count = participants.length;

    // 1 participant or empty fallback
    if (count <= 1) {
      if (participants.isNotEmpty) {
        return _buildCard(participants[0]);
      }
      return FallbackLocalCard(isCameraOn: isCameraOn);
    }

    // 2 participants: 2 cards vertically
    if (count == 2) {
      return Column(
        children: [
          Expanded(child: _buildCard(participants[0])),
          const SizedBox(height: 8),
          Expanded(child: _buildCard(participants[1])),
        ],
      );
    }

    // 3 participants: 2 rows — Row 1: 2 cards, Row 2: 3rd card centered horizontally
    if (count == 3) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - 8).clamp(0.0, double.infinity) / 2;
          return Column(
            children: [
              _buildRow(_buildCard(participants[0]), _buildCard(participants[1])),
              const SizedBox(height: 8),
              _buildCenteredRow(_buildCard(participants[2]), cardWidth),
            ],
          );
        },
      );
    }

    // 4 participants: 2 rows, 2 in each row
    if (count == 4) {
      return Column(
        children: [
          _buildRow(_buildCard(participants[0]), _buildCard(participants[1])),
          const SizedBox(height: 8),
          _buildRow(_buildCard(participants[2]), _buildCard(participants[3])),
        ],
      );
    }

    // 5 participants: 3 rows — Row 1: 2, Row 2: 2, Row 3: 5th centered horizontally
    if (count == 5) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - 8).clamp(0.0, double.infinity) / 2;
          return Column(
            children: [
              _buildRow(_buildCard(participants[0]), _buildCard(participants[1])),
              const SizedBox(height: 8),
              _buildRow(_buildCard(participants[2]), _buildCard(participants[3])),
              const SizedBox(height: 8),
              _buildCenteredRow(_buildCard(participants[4]), cardWidth),
            ],
          );
        },
      );
    }

    // 6 or 7+ participants: 3 rows, 2 in each row (first 6 on screen, 6th shows +N badge if 7+)
    final displayList = participants.take(6).toList();
    final hasMore = count > 6;

    return Column(
      children: [
        _buildRow(_buildCard(displayList[0]), _buildCard(displayList[1])),
        const SizedBox(height: 8),
        _buildRow(_buildCard(displayList[2]), _buildCard(displayList[3])),
        const SizedBox(height: 8),
        _buildRow(
          _buildCard(displayList[4]),
          hasMore
              ? Stack(
                  children: [
                    Positioned.fill(child: _buildCard(displayList[5])),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onShowAllParticipants,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${count - 6}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildCard(displayList[5]),
        ),
      ],
    );
  }

  Widget _buildCard(Participant p) {
    return ParticipantCard(
      participant: p,
      isMicOn: isMicOn,
      isCameraOn: isCameraOn,
    );
  }

  Widget _buildRow(Widget card1, Widget card2) {
    return Expanded(
      child: Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 8),
          Expanded(child: card2),
        ],
      ),
    );
  }

  Widget _buildCenteredRow(Widget card, double cardWidth) {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: cardWidth,
          height: double.infinity,
          child: card,
        ),
      ),
    );
  }
}
