import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallBusyHandler {
  void execute(ServerEventService service, CallBusyEvent event) {
    service.store.setBusy(CallStatus.busy);
    debugPrint('[ServerEvents] User busy: ${event.busyUser}');
  }
}

