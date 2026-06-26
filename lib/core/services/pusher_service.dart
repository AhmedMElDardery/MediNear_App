import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();

  factory PusherService() {
    return _instance;
  }

  PusherService._internal();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> initPusher({
    required String appKey,
    required String cluster,
    required String channelName,
    required String eventName,
    required String token,
    required void Function(dynamic channelName, dynamic data)? onSubscriptionSucceeded,
    required void Function(String message, dynamic error)? onSubscriptionError,
    required void Function(dynamic currentState, dynamic previousState)? onConnectionStateChange,
    required void Function(String message, int? code, dynamic e)? onErrorCallback,
    required void Function(dynamic) onEvent,
  }) async {
    try {
      await pusher.init(
        apiKey: appKey,
        cluster: cluster,
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          try {
            var authUrl = 'https://medinear-eg.com/api/broadcasting/auth';
            var result = await Dio().post(
              authUrl,
              data: {
                'socket_id': socketId,
                'channel_name': channelName
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
                validateStatus: (status) => true, // Accept all statuses so we can see the exact error
              ),
            );
            
            if (result.statusCode != 200) {
               throw Exception('Auth failed with status ${result.statusCode}: ${result.data}');
            }
            
            // Laravel broadcast auth returns JSON string or Map depending on Dio parsing
            return result.data is String ? jsonDecode(result.data) : result.data;
          } catch (e) {
            log("Pusher Auth Error: $e");
            rethrow;
          }
        },
        onConnectionStateChange: (dynamic currentState, dynamic previousState) {
          if (onConnectionStateChange != null) onConnectionStateChange(currentState, previousState);
        },
        onError: (String message, int? code, dynamic e) {
          if (onErrorCallback != null) onErrorCallback(message, code, e);
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          if (onSubscriptionSucceeded != null) {
            onSubscriptionSucceeded(channelName, data);
          }
        },
        onEvent: (dynamic event) {
          log("Pusher Received Event: ${event.eventName}");
          log("Pusher Event Data: ${event.data}");
          
          onEvent(event); // PASS THE WHOLE EVENT!
        },
        onSubscriptionError: (String message, dynamic error) {
          if (onSubscriptionError != null) {
            onSubscriptionError(message, error);
          }
        },
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        authParams: {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }
        },
        authEndpoint: 'https://medinear-eg.com/api/broadcasting/auth', // Standard Laravel API auth endpoint
      );

      await pusher.subscribe(
        channelName: channelName,
      );
      await pusher.connect();
    } catch (e) {
      log("Pusher ERROR: $e");
      if (onErrorCallback != null) {
        onErrorCallback("Init Exception", null, e);
      }
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Pusher Connection State changed from $previousState to $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("Pusher onError: $message code: $code exception: $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("Pusher onSubscriptionSucceeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("Pusher onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("Pusher onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("Pusher onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("Pusher onMemberRemoved: $channelName user: $member");
  }
  
  Future<void> disconnect() async {
    await pusher.disconnect();
  }
}
