import 'package:flutter/foundation.dart';
import '../models/call_model.dart';
import '../store/chat_storage.dart';

/// Service helper class to handle incoming WebSocket message events.
///
/// Follows industry best practices (similar to Teams/Google Meet architecture) by
/// separating incoming event routing, validation, mapping, and persistence
/// into distinct, single-responsibility handler methods.
class BtcMeetSocketEventHandler {
  BtcMeetSocketEventHandler._();

  static final BtcMeetSocketEventHandler _instance = BtcMeetSocketEventHandler._();

  /// Singleton instance of [BtcMeetSocketEventHandler]
  static BtcMeetSocketEventHandler get instance => _instance;

  /// Main dispatcher that receives, identifies, and routes the [WsEvent]
  /// to the appropriate handler method.
  void handleEvent(WsEvent event) {
    try {
      final payload = event.payload;
      if (payload == null) {
        debugPrint('[BtcMeetSocketEventHandler] Event "${event.event}" has null payload. Skipping.');
        return;
      }

      switch (event.event) {
        case WsEvents.newMessage:
          if (payload is Map<String, dynamic>) {
            _handleNewMessage(payload);
          } else {
            debugPrint('[BtcMeetSocketEventHandler] Invalid payload type for newMessage: ${payload.runtimeType}');
          }
          break;

        case WsEvents.messageSent:
          if (payload is Map<String, dynamic>) {
            _handleMessageSent(payload);
          } else {
            debugPrint('[BtcMeetSocketEventHandler] Invalid payload type for messageSent: ${payload.runtimeType}');
          }
          break;

        case WsEvents.seen:
          if (payload is Map<String, dynamic>) {
            _handleMessageSeen(payload);
          } else {
            debugPrint('[BtcMeetSocketEventHandler] Invalid payload type for seen: ${payload.runtimeType}');
          }
          break;

        default:
          debugPrint('[BtcMeetSocketEventHandler] Unhandled database sync event type: ${event.event}');
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('[BtcMeetSocketEventHandler] Local DB sync error for event "${event.event}": $e\n$stackTrace');
    }
  }

  /// Handles incoming new message event.
  /// Decodes payload, saves/inserts message into local Hive database.
  void _handleNewMessage(Map<String, dynamic> payload) {
    final msg = Message.fromJson(payload);
    debugPrint('[BtcMeetSocketEventHandler] Handling newMessage: ${msg.messageId}');
    ChatStorage.instance.saveMessage(msg);
  }

  /// Handles notification that a message sent from this client was successfully pushed.
  /// Updates local message status to 2 (Pushed) in the Hive database.
  void _handleMessageSent(Map<String, dynamic> payload) {
    final msg = Message.fromJson(payload);
    debugPrint('[BtcMeetSocketEventHandler] Handling messageSent: ${msg.messageId}');
    
    final updatedMsg = Message(
      id: msg.id,
      messageId: msg.messageId,
      conversationId: msg.conversationId,
      senderId: msg.senderId,
      type: msg.type,
      content: msg.content,
      fileUrl: msg.fileUrl,
      replyTo: msg.replyTo,
      mentions: msg.mentions,
      reactions: msg.reactions,
      clientType: msg.clientType,
      createdAt: msg.createdAt,
      editedAt: msg.editedAt,
      status: 2, // 2 = Pushed
    );
    ChatStorage.instance.saveMessage(updatedMsg);
  }

  /// Handles message read/seen notification.
  /// Updates the message status to 3 (Seen) in the Hive database if it exists.
  void _handleMessageSeen(Map<String, dynamic> payload) {
    final seenEvent = MessageSeen.fromJson(payload);
    debugPrint('[BtcMeetSocketEventHandler] Handling messageSeen for messageId: ${seenEvent.messageId}');
    
    final oldMsg = ChatStorage.instance.getMessage(seenEvent.messageId);
    if (oldMsg != null) {
      final updatedMsg = Message(
        id: oldMsg.id,
        messageId: oldMsg.messageId,
        conversationId: oldMsg.conversationId,
        senderId: oldMsg.senderId,
        type: oldMsg.type,
        content: oldMsg.content,
        fileUrl: oldMsg.fileUrl,
        replyTo: oldMsg.replyTo,
        mentions: oldMsg.mentions,
        reactions: oldMsg.reactions,
        clientType: oldMsg.clientType,
        createdAt: oldMsg.createdAt,
        editedAt: oldMsg.editedAt,
        status: 3, // 3 = Seen
      );
      ChatStorage.instance.saveMessage(updatedMsg);
    } else {
      debugPrint('[BtcMeetSocketEventHandler] Message not found in local cache for seen event: ${seenEvent.messageId}');
    }
  }
}
