import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color _electricBlue = Color(0xFF06B6D4);
  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : AppTheme.surface(context),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D1228) : AppTheme.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppTheme.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Header Card ──
                _buildHeaderCard(context),
                const SizedBox(height: 24),

                // ── Sections ──
                _buildSection(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: '1. Introduction',
                  content:
                      'Confeet Meet ("we", "our", or "us") provides a modern enterprise communication platform for HD video conferencing, crystal-clear audio calls, real-time collaboration, and messaging. This Privacy Policy explains how we collect, use, process, and protect your information when you access or use the Confeet Meet mobile and desktop applications.\n\nBy using Confeet Meet, you consent to the data collection and practices described in this policy. If you do not agree, please discontinue use of the service.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.storage_rounded,
                  title: '2. Information We Collect',
                  content:
                      'We collect only the minimum necessary information required to provide reliable and secure communication services:\n\n'
                      '• Account & Identity Data: Work email address, full name, organization membership, job title, and profile picture provided by you or your workplace administrator.\n'
                      '• Meeting & Session Information: Meeting room identifiers, scheduled dates, duration, participant roster, and connection status.\n'
                      '• Audio & Video Streams: Real-time audio and video transmitted during active meetings. We do NOT record, save, or harvest video or audio feeds unless a meeting host explicitly initiates a recording session, during which all participants receive visual notifications.\n'
                      '• Live Captions & Transcriptions: When voice recognition or live captioning is enabled, spoken audio is processed transiently to produce real-time captions and summaries. Spoken audio is never sold or used for ad targeting.\n'
                      '• Messages & Shared Files: Text messages, attachments, and documents shared in meetings or team chats, stored securely for participant access.\n'
                      '• Technical Telemetry: Device model, operating system, network quality, and WebRTC performance statistics used exclusively for troubleshooting and call quality optimization.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.security_rounded,
                  title: '3. Device Permissions & Usage',
                  content:
                      'To enable meeting functionalities, Confeet Meet requests specific device permissions. Each permission is used solely for its declared purpose:\n\n'
                      '• Camera (NSCameraUsageDescription): Required to broadcast video during meetings when you switch your camera on. You can mute your camera at any time.\n'
                      '• Microphone (NSMicrophoneUsageDescription): Required to transmit your voice during audio/video calls and enable speech recognition when activated.\n'
                      '• Bluetooth (NSBluetoothAlwaysUsageDescription): Required to route crystal-clear meeting audio to your Bluetooth headsets, AirPods, and external speakers.\n'
                      '• Speech Recognition (NSSpeechRecognitionUsageDescription): Used to transcribe speech into real-time meeting captions and text notes upon your request.\n'
                      '• Notifications: Used to alert you to scheduled meetings, incoming calls, and team messages.\n'
                      '• Background Audio: Allows audio conferences to stay seamlessly connected if you switch apps or lock your device during an active call.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: '4. Security & Encryption Standards',
                  content:
                      'Protecting your communication is central to Confeet Meet:\n\n'
                      '• All real-time media streams (audio, video, screen share) are transmitted over encrypted WebRTC channels using DTLS and SRTP.\n'
                      '• Data in transit between your device and Confeet servers is secured using modern TLS 1.3 / HTTPS encryption.\n'
                      '• Authentication tokens and user credentials are saved securely using hardware-backed platform storage (iOS Keychain and Android Keystore) via Flutter Secure Storage.\n'
                      '• We implement strict role-based access controls and organizational firewalls to safeguard enterprise data.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.share_location_rounded,
                  title: '5. Third Parties & Data Sharing',
                  content:
                      '• Zero Sale of Data: We never sell, rent, or trade your personal information, communications, or meeting recordings to third parties or advertising networks.\n'
                      '• Service Providers: We partner with secure infrastructure providers (including WebRTC media server operators) strictly to host and relay real-time communications under strict confidentiality agreements.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.delete_outline_rounded,
                  title: '6. Data Retention & Account Deletion',
                  content:
                      'In accordance with Apple App Store Review Guidelines and data privacy laws (GDPR, CCPA):\n\n'
                      '• Retention: We retain user data only for the duration of active account membership in your organization.\n'
                      '• Account & Data Deletion: You or your organization administrator may request the permanent deletion of your account, meeting history, and chat messages at any time.\n'
                      '• Deletion Request: To request complete account and data erasure, contact your organization IT administrator or email us directly at privacy@confeet.com. Requests are honored and processed within 30 days.',
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  icon: Icons.contact_support_outlined,
                  title: '7. Contact & Privacy Support',
                  content:
                      'If you have questions, feedback, or privacy requests regarding this policy or how your data is handled, please contact our Data Protection Team:\n\n'
                      '• Email: privacy@confeet.com\n'
                      '• Support: support@confeet.com\n'
                      '• Official Website: https://www.confeet.com',
                ),
                const SizedBox(height: 24),

                // ── Contact Support Card ──
                _buildContactCard(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_richIndigo, _neonPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: _richIndigo.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.privacy_tip_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confeet Meet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Privacy & Security Commitment',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: September 2026',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141933) : AppTheme.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _electricBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _electricBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppTheme.textSecondary(context),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141933) : AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _electricBlue.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: _electricBlue, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have privacy questions?',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Contact privacy@confeet.com',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'privacy@confeet.com'));
              Get.snackbar(
                'Copied',
                'privacy@confeet.com copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: _electricBlue,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _richIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Copy Email', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
