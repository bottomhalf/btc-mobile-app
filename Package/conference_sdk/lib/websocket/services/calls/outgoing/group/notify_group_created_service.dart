import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';

class NotifyGroupCreatedService {
  void execute(String conversationId, String callerId) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.eventGroupNotification,
      GroupNotificationEvent(
        conversationId: conversationId,
        notificationType: NotificationEventType.gnGroupCreated,
        callerId: callerId,
      ).toJson(),
    );
  }
}

