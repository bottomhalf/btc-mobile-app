import 'package:conference/models/api_response.dart';
import 'package:conference/models/quick_meetings.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference/services/meeting_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetController extends GetxController {
  final tokenCtrl = TextEditingController();
  final roomIdCtrl = TextEditingController();
  final accessCodeCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final http = HttpService.instance;
  final _user = UserModel.instance;

  final isJoining = false.obs;

  // ─── Recent Meetings ────────────────────────────────────────────
  final quickMeetings = <QuickMeetings>[].obs;
  final isLoadingMeetings = true.obs;
  final meetingsError = Rxn<String>();

  Future<void> fetchRecentMeetings() async {
    isLoadingMeetings.value = true;
    meetingsError.value = null;

    try {
      ApiResponse response = await http.get('meeting/getAllMeetingByOrganizer');

      if (response.responseBody != null) {
        final body = response.responseBody as Map<String, dynamic>;
        final data = body['QuickMeetings'] as List<dynamic>? ?? [];
        final meetings = data
            .map((e) => QuickMeetings.fromJson(e as Map<String, dynamic>))
            .take(6)
            .toList();
        quickMeetings.value = meetings;
      }
    } catch (e) {
      debugPrint('Failed to load recent meetings: $e');
      meetingsError.value = e.toString();
    } finally {
      isLoadingMeetings.value = false;
    }
  }

  /// Open a recent meeting → triggers the PiP overlay.
  void openMeeting(QuickMeetings meeting) {
    isJoining.value = true;
    try {
      MeetingService.instance.joinMeeting(
        roomId: meeting.meetingId,
        participantName: _user.fullName,
        meetingTitle: meeting.title,
      );
    } catch (e) {
      Get.snackbar(
        'Connection Failed',
        'Failed to join: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isJoining.value = false;
    }
  }

  // ─── Join Meeting ───────────────────────────────────────────────

  Future<void> joinMeeting() async {
    if (!formKey.currentState!.validate()) return;

    isJoining.value = true;
    try {
      MeetingService.instance.joinMeeting(
        roomId: roomIdCtrl.text.trim(),
        participantName: 'Vivek Kumar',
      );
    } catch (e) {
      Get.snackbar(
        'Connection Failed',
        'Failed to join: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isJoining.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    roomIdCtrl.text = '694f949da08d8877589cbdda';
    accessCodeCtrl.text = "1244o1i434k8974r";
    fetchRecentMeetings();
  }

  @override
  void onClose() {
    tokenCtrl.dispose();
    roomIdCtrl.dispose();
    super.onClose();
  }
}
