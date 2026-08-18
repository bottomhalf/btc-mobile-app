import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/call_model.dart';

/// Local persistent storage service inside conference_sdk to handle message caching,
/// sync queue, and offline-first state operations.
class ChatStorage {
  ChatStorage._();
  static final ChatStorage _instance = ChatStorage._();
  static ChatStorage get instance => _instance;

  static const String _boxName = 'btcmeet_chat_storage';
  Box? _box;

  /// Initializes the local storage box. Should be called during application startup.
  Future<void> initialize() async {
    if (_box != null) return;
    try {
      _box = await Hive.openBox(_boxName);
      debugPrint('[ChatStorage] Box "$_boxName" initialized successfully.');
    } catch (e) {
      debugPrint('[ChatStorage] Failed to initialize Box "$_boxName": $e');
    }
  }

  /// Checks if initialized, and throws if accessed prematurely.
  Box get box {
    if (_box == null) {
      throw StateError('[ChatStorage] ChatStorage is not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // ─── CRUD Operations ───────────────────────────────────────────

  /// Create / Save a new Message
  Future<void> saveMessage(Message message) async {
    try {
      await box.put(message.messageId, jsonEncode(message.toJson()));
      debugPrint('[ChatStorage] Saved message: ${message.messageId}');
    } catch (e) {
      debugPrint('[ChatStorage] Error saving message ${message.messageId}: $e');
    }
  }

  /// Read / Get a single Message by ID
  Message? getMessage(String messageId) {
    try {
      final raw = box.get(messageId);
      if (raw == null) return null;
      if (raw is String) {
        return Message.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('[ChatStorage] Error reading message $messageId: $e');
      return null;
    }
  }

  /// Read / Get all saved Messages (useful for offline resending)
  List<Message> getAllMessages() {
    try {
      final List<Message> list = [];
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is String) {
          list.add(Message.fromJson(jsonDecode(raw) as Map<String, dynamic>));
        }
      }
      return list;
    } catch (e) {
      debugPrint('[ChatStorage] Error reading all messages: $e');
      return [];
    }
  }

  /// Update an existing Message
  Future<void> updateMessage(Message message) async {
    await saveMessage(message);
  }

  /// Delete a Message by ID
  Future<void> deleteMessage(String messageId) async {
    try {
      await box.delete(messageId);
      debugPrint('[ChatStorage] Deleted message: $messageId');
    } catch (e) {
      debugPrint('[ChatStorage] Error deleting message $messageId: $e');
    }
  }

  /// Clear all stored messages
  Future<void> clearAll() async {
    try {
      await box.clear();
      debugPrint('[ChatStorage] All cached chat messages cleared.');
    } catch (e) {
      debugPrint('[ChatStorage] Error clearing box: $e');
    }
  }
}
