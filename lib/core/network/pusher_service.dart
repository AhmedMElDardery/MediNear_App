import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer';

class PusherService {
  final Dio dio;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;
  
  // Store listeners by channel name
  final Map<String, Function(PusherEvent)> _channelListeners = {};

  PusherService({required this.dio});

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _pusher.init(
        apiKey: "0f70acb0d542c5b87ebf",
        cluster: "eu",
        onAuthorizer: _onAuthorizer,
        onConnectionStateChange: (currentState, previousState) {
          log("Connection: $currentState");
        },
        onError: (message, code, error) {
          log("Pusher Error: $message");
        },
        onEvent: (PusherEvent event) {
          log("Global Event Received: Channel: ${event.channelName}, Event: ${event.eventName}");
          final listener = _channelListeners[event.channelName];
          if (listener != null) {
            listener(event);
          } else {
             // Fallback for empty channel or global
             for (var l in _channelListeners.values) {
                l(event);
             }
          }
        },
      );
      await _pusher.connect();
      _isInitialized = true;
    } catch (e) {
      log("Pusher Init Error: $e");
    }
  }

  // Custom Authorizer to pass Bearer Token via existing Dio setup
  dynamic _onAuthorizer(
      String channelName, String socketId, dynamic options) async {
    try {
      final response = await dio.post(
        '/broadcasting/auth', // standard auth route in laravel, since dio base URL is likely /api, this points to /api/broadcasting/auth
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );
      return response.data;
    } catch (e) {
      log("Auth Error: $e");
      throw Exception("Failed to authorize Pusher channel");
    }
  }

  Future<void> subscribeToChat(int sessionId, Function(PusherEvent) onMessage) async {
    await init();
    try {
      // Laravel Echo prefixes private channels with 'private-'
      final channelName = 'private-chat.$sessionId';
      _channelListeners[channelName] = onMessage;
      
      await _pusher.subscribe(
        channelName: channelName,
      );
      log("Subscribed to $channelName");
    } catch (e) {
      log("Subscribe Error: $e");
    }
  }

  Future<void> unsubscribeFromChat(int sessionId) async {
    try {
      final channelName = 'private-chat.$sessionId';
      await _pusher.unsubscribe(channelName: channelName);
      _channelListeners.remove(channelName);
      log("Unsubscribed from $channelName");
    } catch (e) {
      log("Unsubscribe Error: $e");
    }
  }

  Future<void> subscribeToNotifications(String userId, Function(PusherEvent) onMessage) async {
    await init();
    try {
      final channelName = 'private-App.Models.User.$userId';
      _channelListeners[channelName] = onMessage;
      
      await _pusher.subscribe(
        channelName: channelName,
      );
      log("Subscribed to $channelName");
    } catch (e) {
      log("Subscribe Notifications Error: $e");
    }
  }

  Future<void> unsubscribeFromNotifications(String userId) async {
    try {
      final channelName = 'private-App.Models.User.$userId';
      await _pusher.unsubscribe(channelName: channelName);
      _channelListeners.remove(channelName);
      log("Unsubscribed from notifications ($channelName)");
    } catch (e) {
      log("Unsubscribe Notifications Error: $e");
    }
  }
}
