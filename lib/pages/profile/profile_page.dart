import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;

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
          'My Profile',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF131224), Color(0xFF1B1A2E)]
                : const [Color(0xFFF3F5FA), Color(0xFFE8ECF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ─── Header Profile Card with Glassmorphism / Gradient ───
            _buildProfileHeaderCard(context, user),
            const SizedBox(height: 28),

            // ─── Personal Info Section ───
            _buildSectionTitle(context, 'Personal Information'),
            const SizedBox(height: 12),
            _buildPersonalCard(context, user),
            const SizedBox(height: 28),

            // ─── Work & Organization Section ───
            _buildSectionTitle(context, 'Work & Organization'),
            const SizedBox(height: 12),
            _buildWorkCard(context, user),
            const SizedBox(height: 28),

            // ─── Security Disclaimer Banner ───
            _buildSecurityBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPurple,
            AppTheme.primaryIndigo,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        backgroundImage: user.imageUrl.isNotEmpty ? NetworkImage(user.imageUrl) : null,
                        child: user.imageUrl.isEmpty
                            ? Text(
                                controller.initials,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentPurple,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName.trim().isNotEmpty ? user.fullName : 'User Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user.email.trim().isNotEmpty ? user.email : 'user@example.com',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Verified Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.accentPurple,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPersonalCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, Icons.person_outline_rounded, 'First Name', user.firstName),
          _buildDivider(context),
          _buildDetailRow(context, Icons.person_outline_rounded, 'Last Name', user.lastName),
          _buildDivider(context),
          _buildDetailRow(context, Icons.alternate_email_rounded, 'Email Address', user.email),
        ],
      ),
    );
  }

  Widget _buildWorkCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, Icons.vpn_key_outlined, 'User ID', user.userId, copyable: true),
          _buildDivider(context),
          _buildDetailRow(context, Icons.corporate_fare_rounded, 'Organization Code', user.code),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardAlt(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_person_rounded,
              color: AppTheme.accentPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-End Encryption',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile parameters, chats, and scheduled meetings are fully secured and visible only to members of your organization.',
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          if (copyable && value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 18, color: AppTheme.textSecondary(context)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  'Copied',
                  '$label copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.accentPurple,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: AppTheme.divider(context).withValues(alpha: 0.5),
      indent: 68,
    );
  }
}
