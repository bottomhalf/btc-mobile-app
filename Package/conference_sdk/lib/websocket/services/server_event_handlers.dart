import 'server_event_service.dart';
import 'calls/incoming/incoming_call_handler.dart';
import 'calls/incoming/joining_request_handler.dart';
import 'calls/incoming/group_notification_handler.dart';
import 'calls/incoming/raised_joining_request_handler.dart';
import 'calls/incoming/call_accepted_handler.dart';
import 'calls/incoming/call_rejected_handler.dart';
import 'calls/incoming/call_dismissed_handler.dart';
import 'calls/incoming/call_cancelled_handler.dart';
import 'calls/incoming/call_timed_out_handler.dart';
import 'calls/incoming/call_ended_handler.dart';
import 'calls/incoming/call_busy_handler.dart';
import 'calls/incoming/call_error_handler.dart';

/// registerCallEventHandlers
///
/// Wires up all WebSocket server-event subscriptions by delegating to individual 
/// incoming event handlers under `services/calls/incoming/`.
void registerCallEventHandlers(ServerEventService service) {
  // Clear any existing subscriptions before registering new ones
  for (final sub in service.subscriptions) {
    sub.cancel();
  }
  service.subscriptions.clear();

  // ── Incoming Call ────────────────────────────────────────────────────────
  final incomingCall = IncomingCallHandler();
  service.subscriptions.add(
    service.callIncoming$.listen((event) => incomingCall.execute(service, event)),
  );

  // ── Joining Request (invited into ongoing call) ──────────────────────────
  final joiningRequest = JoiningRequestHandler();
  service.subscriptions.add(
    service.callJoiningRequest$.listen((event) => joiningRequest.execute(service, event)),
  );

  // ── Group Notification ───────────────────────────────────────────────────
  final groupNotification = GroupNotificationHandler();
  service.subscriptions.add(
    service.groupNotification$.listen((event) => groupNotification.execute(service, event)),
  );

  // ── Raised Joining Request ───────────────────────────────────────────────
  final raisedJoining = RaisedJoiningRequestHandler();
  service.subscriptions.add(
    service.callRaisedJoiningRequest$.listen((event) => raisedJoining.execute(service, event)),
  );

  // ── Call Accepted ────────────────────────────────────────────────────────
  final callAccepted = CallAcceptedHandler();
  service.subscriptions.add(
    service.callAccepted$.listen((event) => callAccepted.execute(service, event)),
  );

  // ── Call Rejected ────────────────────────────────────────────────────────
  final callRejected = CallRejectedHandler();
  service.subscriptions.add(
    service.callRejected$.listen((event) => callRejected.execute(service, event)),
  );

  // ── Call Dismissed ───────────────────────────────────────────────────────
  final callDismissed = CallDismissedHandler();
  service.subscriptions.add(
    service.callDismissed$.listen((event) => callDismissed.execute(service, event)),
  );

  // ── Call Cancelled ───────────────────────────────────────────────────────
  final callCancelled = CallCancelledHandler();
  service.subscriptions.add(
    service.callCancelled$.listen((event) => callCancelled.execute(service, event)),
  );

  // ── Call Timed Out ───────────────────────────────────────────────────────
  final callTimedOut = CallTimedOutHandler();
  service.subscriptions.add(
    service.callTimedOut$.listen((event) => callTimedOut.execute(service, event)),
  );

  // ── Call Ended ───────────────────────────────────────────────────────────
  final callEnded = CallEndedHandler();
  service.subscriptions.add(
    service.callEnded$.listen((event) => callEnded.execute(service, event)),
  );

  // ── Callee Busy ──────────────────────────────────────────────────────────
  final callBusy = CallBusyHandler();
  service.subscriptions.add(
    service.callBusy$.listen((event) => callBusy.execute(service, event)),
  );

  // ── Call Error ───────────────────────────────────────────────────────────
  final callError = CallErrorHandler();
  service.subscriptions.add(
    service.callError$.listen((event) => callError.execute(service, event)),
  );
}
