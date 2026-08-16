import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/utils/uuid.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class InitiateVideoJoiningRequestService {
  void execute(String calleeId, String conversationId) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.joiningRequest,
      CallInitiatePayload(
        callId: UuidUtils.generateUUID(),
        conversationId: conversationId,
        calleeIds: [calleeId],
        callType: CallType.video,
        timeout: CallConfig.defaultTimeout,
      ).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.initiated;
  }
}

