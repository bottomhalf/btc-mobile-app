import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class EndCallService {
  void execute({String? reason}) {
    final conversationId = BtcMeetSocketService.instance.currentConversationId.value ?? '';
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callEnd,
      CallEndPayload(
        conversationId: conversationId,
        reason: reason ?? CallEndReason.normal,
      ).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.ended;
  }
}

