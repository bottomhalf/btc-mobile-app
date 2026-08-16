import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallDismissedHandler {
  void execute(ServerEventService service, CallDismissedEvent event) {
    service.store.setDismissed();
    debugPrint('[ServerEvents] Call dismissed by: ${event.dismissedBy}');
  }
}

