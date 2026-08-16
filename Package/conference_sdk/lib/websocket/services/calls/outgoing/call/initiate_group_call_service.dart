import 'dart:async';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/utils/uuid.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';
import 'timeout_call_service.dart';

class InitiateGroupCallService {
  final TimeoutCallService _timeoutCallService = TimeoutCallService();

  void execute(List<String> calleeIds, String conversationId, String callType) {
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
        calleeIds: calleeIds,
        callType: callType,
        timeout: CallConfig.defaultTimeout,
      ).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.initiated;

    // Start 120s ring timeout
    Timer(const Duration(seconds: 120), () {
      final currentStatus = ServerEventService.instance.store.callStatus.value;
      if (currentStatus == CallStatus.initiated || currentStatus == CallStatus.ringing) {
        // Time's up! No one answered.
        _timeoutCallService.execute(conversationId, '');

        BtcMeetSocketService.instance.showNotification(
          SdkNotification(
            id: UuidUtils.generateUUID(),
            type: 'warning',
            title: 'No Answer',
            content: 'One or more users did not respond in 2 minutes.',
            conversationId: '',
            timestamp: DateTime.now(),
            read: false,
          ),
        );
      }
    });
  }
}

