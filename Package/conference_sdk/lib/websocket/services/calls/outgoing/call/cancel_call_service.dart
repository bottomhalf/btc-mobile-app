import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CancelCallService {
  void execute(String conversationId, List<String> calleeIds) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callCancel,
      CallCancelPayload(conversationId: conversationId, calleeIds: calleeIds).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.cancelled;
  }
}

