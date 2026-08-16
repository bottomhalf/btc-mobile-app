import 'dart:async';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/utils/uuid.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';
import 'end_call_service.dart';
import 'timeout_call_service.dart';

class InitiateVideoCallService {
  final TimeoutCallService _timeoutCallService = TimeoutCallService();
  final EndCallService _endCallService = EndCallService();

  void execute(dynamic calleeIds, String conversationId, {bool isDirectCall = false}) {
    final List<String> ids = calleeIds is List<String>
        ? calleeIds
        : [calleeIds.toString()];

    final currentUser = BtcMeetSocketService.instance.localUser;
    final callerId = currentUser?.userId ?? '';
    final callerName = currentUser?.fullName ?? '';
    final callerAvatar = currentUser?.avatar ?? '';

    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callInitiate,
      CallInitiatePayload(
        callId: UuidUtils.generateUUID(),
        callerId: callerId,
        callerName: callerName,
        callerAvatar: callerAvatar,
        conversationId: conversationId,
        calleeIds: ids,
        callType: CallType.video,
        timeout: CallConfig.defaultTimeout,
      ).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.initiated;

    // Start 120s ring timeout
    Timer(const Duration(seconds: 120), () {
      final currentStatus = ServerEventService.instance.store.callStatus.value;
      if (currentStatus == CallStatus.initiated || currentStatus == CallStatus.ringing) {
        // Time's up! No one answered.
        final targetId = ids.isNotEmpty ? ids.first : '';
        _timeoutCallService.execute(conversationId, targetId);

        if (isDirectCall || ids.length == 1) {
          BtcMeetSocketService.instance.showNotification(
            SdkNotification(
              id: UuidUtils.generateUUID(),
              type: 'warning',
              title: 'No Answer',
              content: 'The user did not respond in 2 minutes. Disconnecting call.',
              conversationId: '',
              timestamp: DateTime.now(),
              read: false,
            ),
          );
          _endCallService.execute(reason: CallEndReason.timeout);
        } else {
          BtcMeetSocketService.instance.showNotification(
            SdkNotification(
              id: UuidUtils.generateUUID(),
              type: 'warning',
              title: 'No Answer',
              content: 'One or more users did not respond.',
              conversationId: '',
              timestamp: DateTime.now(),
              read: false,
            ),
          );
        }
      }
    });
  }
}

