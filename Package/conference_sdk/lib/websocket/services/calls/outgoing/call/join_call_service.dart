import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class JoinCallService {
  void execute(String calleeId, String conversationId) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callStarted,
      CallInitiatePayload(
        conversationId: conversationId,
        calleeIds: [calleeId],
        callType: CallType.audio,
        timeout: CallConfig.defaultTimeout,
      ).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.initiated;
  }
}

