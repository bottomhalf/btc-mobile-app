import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallAcceptedHandler {
  void execute(ServerEventService service, CallAcceptedEvent event) {
    service.store.setAccepted(CallStatus.accepted);
    debugPrint('[ServerEvents] Call accepted by: ${event.acceptedBy}');
  }
}

