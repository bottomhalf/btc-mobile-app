import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/call_model.dart';
import '../store/call_store.dart';
import 'btcmeet_socket_service.dart';
import 'server_event_handlers.dart';

class ServerEventService {
  // ─── Singleton Pattern ──────────────────────────────────────────
  ServerEventService._() {
    _initStreams();
  }
  static final ServerEventService _instance = ServerEventService._();
  static ServerEventService get instance => _instance;

  // ─── WebSocket Event Streams ────────────────────────────────────
  late final Stream<CallIncomingEvent> callIncoming$;
  late final Stream<List<dynamic>> initUserList$;
  late final Stream<CallIncomingEvent> callJoiningRequest$;
  late final Stream<CallAcceptedEvent> callAccepted$;
  late final Stream<CallRejectedEvent> callRejected$;
  late final Stream<CallDismissedEvent> callDismissed$;
  late final Stream<CallCancelledEvent> callCancelled$;
  late final Stream<CallTimedOutEvent> callTimedOut$;
  late final Stream<CallEndedEvent> callEnded$;
  late final Stream<CallBusyEvent> callBusy$;
  late final Stream<CallErrorEvent> callError$;
  late final Stream<CallIncomingEvent> callRaisedJoiningRequest$;
  late final Stream<GroupNotificationEvent> groupNotification$;

  // ─── Subscriptions List (equivalent to rxjs Subscription bag) ─────
  final List<StreamSubscription> subscriptions = [];

  // Expose the CallStore instance for state access
  CallStore get store => CallStore.instance;

  void _initStreams() {
    callIncoming$ = _onCallEvent<CallIncomingEvent>(
      CallServerEvents.callIncoming,
      (payload) => CallIncomingEvent.fromJson(payload as Map<String, dynamic>),
    );
    initUserList$ = _onCallEvent<List<dynamic>>(
      CallServerEvents.initUserlist,
      (payload) => payload as List<dynamic>,
    );
    callJoiningRequest$ = _onCallEvent<CallIncomingEvent>(
      CallServerEvents.callJoiningRequest,
      (payload) => CallIncomingEvent.fromJson(payload as Map<String, dynamic>),
    );
    callAccepted$ = _onCallEvent<CallAcceptedEvent>(
      CallServerEvents.callAccepted,
      (payload) => CallAcceptedEvent.fromJson(payload as Map<String, dynamic>),
    );
    callRejected$ = _onCallEvent<CallRejectedEvent>(
      CallServerEvents.callRejected,
      (payload) => CallRejectedEvent.fromJson(payload as Map<String, dynamic>),
    );
    callDismissed$ = _onCallEvent<CallDismissedEvent>(
      CallServerEvents.callDismissed,
      (payload) => CallDismissedEvent.fromJson(payload as Map<String, dynamic>),
    );
    callCancelled$ = _onCallEvent<CallCancelledEvent>(
      CallServerEvents.callCancelled,
      (payload) => CallCancelledEvent.fromJson(payload as Map<String, dynamic>),
    );
    callTimedOut$ = _onCallEvent<CallTimedOutEvent>(
      CallServerEvents.callTimedOut,
      (payload) => CallTimedOutEvent.fromJson(payload as Map<String, dynamic>),
    );
    callEnded$ = _onCallEvent<CallEndedEvent>(
      CallServerEvents.callEnded,
      (payload) => CallEndedEvent.fromJson(payload as Map<String, dynamic>),
    );
    callBusy$ = _onCallEvent<CallBusyEvent>(
      CallServerEvents.callBusy,
      (payload) => CallBusyEvent.fromJson(payload as Map<String, dynamic>),
    );
    callError$ = _onCallEvent<CallErrorEvent>(
      CallServerEvents.callError,
      (payload) => CallErrorEvent.fromJson(payload as Map<String, dynamic>),
    );
    callRaisedJoiningRequest$ = _onCallEvent<CallIncomingEvent>(
      CallServerEvents.callRaisedRequest,
      (payload) => CallIncomingEvent.fromJson(payload as Map<String, dynamic>),
    );
    groupNotification$ = _onCallEvent<GroupNotificationEvent>(
      CallServerEvents.callGroupNotification,
      (payload) => GroupNotificationEvent.fromJson(payload as Map<String, dynamic>),
    );
  }

  // ─── Public API ─────────────────────────────────────────────────

  /// Initialize call event listeners.
  /// Subscribes to websocket streams and hooks up the handlers to mutate the store.
  void initialize() {
    registerCallEventHandlers(this);
    debugPrint('[ServerEventService] Initialized and subscribed to call events');
  }

  /// Convenience helper to update room participants.
  void updateParticipantsInRoom(Map<String, CallParticipant> participants) {
    store.setParticipantsInRoom(participants);
  }

  /// Convenience helper to reset call store.
  void resetCallState() {
    store.reset();
  }

  /// Cleanup subscriptions on destroy/logout.
  void destroy() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
    subscriptions.clear();
    debugPrint('[ServerEventService] Subscriptions cleaned up');
  }

  // ─── Private Helper ─────────────────────────────────────────────
  Stream<T> _onCallEvent<T>(String eventType, T Function(dynamic payload) mapper) {
    return BtcMeetSocketService.instance.getMessageSubject().stream
        .where((e) => e.event == eventType)
        .map((e) => mapper(e.payload));
  }
}
