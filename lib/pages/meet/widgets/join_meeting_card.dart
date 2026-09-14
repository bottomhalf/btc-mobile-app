import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../meet_controller.dart';

class JoinMeetingCard extends GetView<MeetController> {
  const JoinMeetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
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
            border: Border.all(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.meeting_room_rounded,
                      color: AppTheme.accentPurple,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Join a Meeting',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                // TextFormField(
                //   controller: controller.serverUrlCtrl,
                //   style: const TextStyle(color: Colors.white, fontSize: 14),
                //   decoration: const InputDecoration(
                //     hintText:
                //         'Server URL (e.g. wss://your-server.livekit.cloud)',
                //     prefixIcon: Icon(Icons.dns_rounded, size: 20),
                //   ),
                //   validator: (v) =>
                //       (v == null || v.trim().isEmpty) ? 'Required' : null,
                // ),
                // const SizedBox(height: 14),
                // TextFormField(
                //   controller: controller.tokenCtrl,
                //   style: const TextStyle(color: Colors.white, fontSize: 14),
                //   obscureText: true,
                //   decoration: const InputDecoration(
                //     hintText: 'Access Token',
                //     prefixIcon: Icon(Icons.vpn_key_rounded, size: 20),
                //   ),
                //   validator: (v) =>
                //       (v == null || v.trim().isEmpty) ? 'Required' : null,
                // ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller.roomIdCtrl,
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Room ID',
                    prefixIcon: Icon(Icons.tag_rounded, size: 20),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller.accessCodeCtrl,
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 14,
                  ),
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Access Passcode (Optional)',
                    prefixIcon: Icon(Icons.vpn_key_rounded, size: 20),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isJoining.value
                            ? null
                            : controller.joinMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isJoining.value
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('Join Now'),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
