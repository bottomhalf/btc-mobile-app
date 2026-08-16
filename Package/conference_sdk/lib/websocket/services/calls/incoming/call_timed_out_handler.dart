import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallTimedOutHandler {
  void execute(ServerEventService service, CallTimedOutEvent event) {
    service.store.setTimedOut(CallStatus.timeout);
    debugPrint('[ServerEvents] Call timed out: ${event.conversationId}');
  }
}

