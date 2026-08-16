import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class GroupNotificationHandler {
  void execute(ServerEventService service, GroupNotificationEvent event) {
    debugPrint('[ServerEvents] Group notification: $event');
    service.store.setGroupNotification(event);
  }
}

