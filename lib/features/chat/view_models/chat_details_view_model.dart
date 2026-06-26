import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medinear_app/features/chat/data/models/message_model.dart';
import 'package:medinear_app/features/chat/data/repositories/chat_repository.dart';
import 'package:medinear_app/core/network/pusher_service.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ChatDetailsViewModel extends ChangeNotifier {
  final ChatRepository repository;
  final PusherService pusherService;
  final int sessionId;
  final TextEditingController messageController = TextEditingController();

  List<MessageModel> messages = [];
  bool isLoading = false;
  String? errorMessage;

  ChatDetailsViewModel({
    required this.repository, 
    required this.pusherService, 
    required this.sessionId
  }) {
    fetchMessages();
    _initPusher();
  }

  void _initPusher() {
    pusherService.subscribeToChat(sessionId, _onPusherEvent);
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.data == null) return;
    
    // Handle MessageRead event to update double ticks to blue!
    if (event.eventName == 'App\\Events\\MessageRead' || 
        event.eventName == '.App\\Events\\MessageRead' || 
        event.eventName == 'MessageRead') {
      
      bool changed = false;
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].isMe && !messages[i].isRead) {
          messages[i] = MessageModel(
            id: messages[i].id,
            text: messages[i].text,
            time: messages[i].time,
            isMe: messages[i].isMe,
            isRead: true,
            filePath: messages[i].filePath,
            type: messages[i].type,
          );
          changed = true;
        }
      }
      if (changed) notifyListeners();
      return;
    }

    // Handle MessageSent event
    if (event.eventName == 'App\\Events\\MessageSent' || 
        event.eventName == '.App\\Events\\MessageSent' || 
        event.eventName == 'MessageSent') {
      try {
        final decoded = jsonDecode(event.data.toString());
        final messageData = decoded['message'] ?? decoded;
        
        if (messageData is Map<String, dynamic> && messageData.containsKey('id')) {
          final newMessage = MessageModel.fromJson(messageData);
          final existingIndex = messages.indexWhere((m) => m.id == newMessage.id);
          
          if (existingIndex != -1) {
            messages[existingIndex] = newMessage;
            notifyListeners();
          } else {
            messages.add(newMessage);
            notifyListeners();
          }
        }
      } catch (e) {
        log("Error parsing Pusher event: $e");
      }
    }
  }

  Future<void> fetchMessages() async {
    // 🚀 جلب الرسائل المخزنة محلياً أولاً ليتم عرضها فوراً وبدون تأخير
    try {
      final cachedMessages = await repository.getCachedMessages(sessionId);
      if (cachedMessages.isNotEmpty) {
        messages = cachedMessages;
        notifyListeners();
      } else {
        // إذا لم يكن هناك رسائل مخزنة، نعرض مؤشر التحميل
        isLoading = true;
        notifyListeners();
      }
    } catch (e) {
      log("Error loading cached messages: $e");
    }

    // 🚀 جلب الرسائل الجديدة من السيرفر وتحديث الشاشة في الخلفية
    try {
      final newMessages = await repository.getMessages(sessionId);
      
      // Prevent unnecessary flicker if the cached messages are identical to the API ones
      if (messages.length != newMessages.length || messages.isEmpty || messages.first.id != newMessages.first.id) {
        messages = newMessages;
        notifyListeners();
      } else {
        // Even if length is same, we might have updated statuses (read etc), so we update it silently
        // or notify if needed. For now, let's just update and notify to be safe.
        messages = newMessages;
        notifyListeners();
      }
      repository.readSession(sessionId).catchError((_) {});
    } catch (e) {
      if (messages.isEmpty) {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    // Add locally to seem fast
    messages.add(
      MessageModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        time:
            "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}",
        isMe: true,
      ),
    );
    notifyListeners();

    try {
      final sentMessage = await repository.sendNewMessage(sessionId, text);
      // Replace the local message with the real one
      messages.removeWhere((m) => m.id.startsWith('temp_') && m.text == text);
      
      if (!messages.any((m) => m.id == sentMessage.id)) {
        messages.add(sentMessage);
      }
    } catch (e) {
      // Remove the optimistic message because sending failed
      messages.removeWhere((m) => m.id.startsWith('temp_') && m.text == text);
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  bool isMuted = false;

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void clearChatLocally() {
    messages.clear();
    notifyListeners();
  }

  Future<void> pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null) return;
    
    final file = File(pickedFile.path);
    await _uploadFileWithOptimisticUI(file, 'image');
  }

  Future<void> pickAndSendCameraImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile == null) return;
    
    final file = File(pickedFile.path);
    await _uploadFileWithOptimisticUI(file, 'image');
  }

  Future<void> pickAndSendDocument() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      await _uploadFileWithOptimisticUI(File(result.files.single.path!), 'file');
    }
  }

  Future<void> pickAndSendAudioFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      await _uploadFileWithOptimisticUI(File(result.files.single.path!), 'audio');
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage = 'Location services are disabled.';
        notifyListeners();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage = 'Location permissions are denied';
          notifyListeners();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        errorMessage = 'Location permissions are permanently denied.';
        notifyListeners();
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      String locationLink = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      
      messageController.text = locationLink;
      await sendMessage();
    } catch (e) {
      log('Error getting location: $e');
    }
  }

  Future<void> pickAndSendContact() async {
    if (await FlutterContacts.permissions.request(PermissionType.read) == PermissionStatus.granted) {
      Contact? contact = await FlutterContacts.native.showPicker(properties: {ContactProperty.phone});
      if (contact != null) {
        String contactDetails = 'جهة اتصال: ${contact.displayName}';
        if (contact.phones.isNotEmpty) {
          contactDetails += '\nرقم الهاتف: ${contact.phones.first.number}';
        }
        messageController.text = contactDetails;
        await sendMessage();
      }
    } else {
      errorMessage = 'Contact permission denied';
      notifyListeners();
    }
  }

  // Helper method for file uploads
  Future<void> _uploadFileWithOptimisticUI(File file, String type) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add optimistic message
    messages.add(
      MessageModel(
        id: tempId,
        text: type == 'image' ? 'صورة' : (type == 'audio' ? 'مقطع صوتي' : 'مستند'),
        time: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}",
        isMe: true,
        type: type,
        filePath: file.path, 
      ),
    );
    notifyListeners();

    try {
      final sentMessage = await repository.sendNewMessage(
        sessionId, 
        '', 
        imageFile: type == 'image' ? file : null,
        audioFile: type == 'audio' ? file : null,
        documentFile: type == 'file' ? file : null,
      );
      messages.removeWhere((m) => m.id == tempId);
      
      if (!messages.any((m) => m.id == sentMessage.id)) {
        messages.add(sentMessage);
      }
    } catch (e) {
      messages.removeWhere((m) => m.id == tempId);
      errorMessage = "Failed to upload $type: $e";
    }
    notifyListeners();
  }

  // --- AUDIO RECORDING LOGIC ---
  final _audioRecorder = AudioRecorder();
  bool isRecording = false;
  int recordingDuration = 0;
  Timer? _recordingTimer;

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        isRecording = true;
        recordingDuration = 0;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          recordingDuration++;
          notifyListeners();
        });
        notifyListeners();
      } else {
        errorMessage = "Microphone permission denied";
        notifyListeners();
      }
    } catch (e) {
      log("Error starting record: $e");
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;
    
    // إيقاف الحالة فوراً لمنع التكرار
    isRecording = false;
    _recordingTimer?.cancel();
    final int duration = recordingDuration;
    recordingDuration = 0;
    notifyListeners();

    try {
      final path = await _audioRecorder.stop();
      if (path != null && duration > 0) {
        final file = File(path);
        await _uploadFileWithOptimisticUI(file, 'audio');
      } else if (path != null) {
        // حذف الملف لو كان 0 ثانية
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      log("Error stopping record: $e");
    }
  }

  Future<void> cancelRecording() async {
    if (!isRecording) return;
    
    // إيقاف الحالة فوراً لمنع التكرار من السحب السريع
    isRecording = false;
    _recordingTimer?.cancel();
    recordingDuration = 0;
    notifyListeners();

    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      log("Error canceling record: $e");
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    messageController.dispose();
    _audioRecorder.dispose();
    pusherService.unsubscribeFromChat(sessionId);
    super.dispose();
  }
}


