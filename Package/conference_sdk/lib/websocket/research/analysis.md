# WebSocket Code Conversion Analysis

We analyzed the WebSocket-related code in the Angular application (`btc-web-conference`) and established a mapping and architecture for the Flutter package (`conference_sdk`).

## TS to Dart File Map

| Angular File Path | Flutter Destination Path |
|---|---|
| `models/conference_call/call_model.ts` | `lib/websocket/models/call_model.dart` |
| `providers/socket/confeet-socket.service.ts` | `lib/websocket/services/btcmeet_socket_service.dart` |
| `providers/socket/server-events/server-event.service.ts` | `lib/websocket/services/server_event_service.dart` |
| `providers/socket/server-events/server-event.handlers.ts` | `lib/websocket/services/server_event_handlers.dart` |
| `providers/socket/client-events/call/*.ts` | `lib/websocket/services/client_events/call/*.dart` |
| `providers/socket/client-events/group/notify-group-created.service.ts` | `lib/websocket/services/client_events/group/notify_group_created_service.dart` |

---

## Architectural Decisions

### 1. `dart:io` WebSocket Implementation
Unlike the main app which uses `web_socket_channel`, we will use `dart:io`'s native `WebSocket` class as requested.
- We will manage connection states, socket streams, heartbeats, and re-connection logic inside `BtcMeetSocketService`.
- Reconnection will attempt every 3 seconds if the socket disconnects.
- Heartbeats (ping) will be sent at the interval specified (default 30 seconds) to keep the connection alive.

### 2. Event Streaming
Instead of RxJS Observables, we will use native Dart `Stream` and `StreamController`.
- A single broadcast `StreamController<WsEvent>` will stream all incoming event payloads.
- We will filter and map events using `.where()` and `.map()` to create specialized streams equivalent to Angular's event observables.

### 3. Models and Serialization
All payload interfaces in `call_model.ts` will be converted to strongly-typed Dart classes with `fromJson` and `toJson` support.

### 4. Dependency Injection & Integration
- For services like `LocalService` or `NotificationService`, we will define abstract interfaces or pass callbacks so that the host application or SDK user can plug in their own user provider and notification UI. This keeps `conference_sdk` decoupled and reusable.
