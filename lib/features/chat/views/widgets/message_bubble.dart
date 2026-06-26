import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medinear_app/features/chat/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = message.isMe;
    
    // تحديد نوع المرفق بناءً على الامتداد أو النص الافتراضي
    String path = message.filePath?.toLowerCase() ?? '';
    bool isAudioPath = path.endsWith('.m4a') || path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.ogg') || path.endsWith('.webm') || path.endsWith('.aac');
    
    bool isAudio = message.type == 'audio' || message.type == 'voice' || message.text == 'مقطع صوتي' || (message.filePath != null && isAudioPath);
    bool isDocument = message.type == 'file' || message.text == 'مستند';
    bool isLocation = message.text.contains('maps.google.com') || message.text.contains('google.com/maps');
    bool isContact = message.text.startsWith('جهة اتصال:');
    bool hasImage = !isAudio && !isDocument && (message.filePath != null || message.type == 'image' || message.text == 'صورة');

    // لنجعل خلفية الموقع وجهة الاتصال بيضاء مع حدود إذا لم تكن صورة
    bool isSpecialCard = isLocation || isContact || isDocument;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && !isAudio && !isSpecialCard) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: (hasImage && !isAudio) 
                      ? const EdgeInsets.all(4) 
                      : (isAudio ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.5)),
                  ),
                  child: isAudio
                      ? AudioPlayerWidget(
                          url: message.filePath ?? '',
                          isLocal: message.filePath != null && !message.filePath!.startsWith('http'),
                          isMe: isMe,
                          time: message.time,
                          isRead: message.isRead,
                        )
                      : isDocument
                          ? _buildDocumentCard(context, isMe)
                          : isLocation
                              ? _buildLocationCard(context, isMe)
                              : isContact
                                  ? _buildContactCard(context, isMe)
                                  : hasImage
                                      ? GestureDetector(
                                          onTap: () {
                                            if (message.filePath != null) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => FullScreenImageScreen(
                                                    imagePath: message.filePath!,
                                                    isNetwork: message.filePath!.startsWith('http'),
                                                    heroTag: message.id,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Hero(
                                            tag: message.id,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: message.filePath != null && message.filePath!.startsWith('http')
                                                  ? Image.network(
                                                      message.filePath!,
                                                      width: 200,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
                                                    )
                                                  : (message.filePath != null 
                                                      ? Image.file(
                                                          File(message.filePath!),
                                                          width: 200,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : const SizedBox(
                                                          width: 200,
                                                          height: 150,
                                                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                                                        )),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          message.text,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Theme.of(context).textTheme.bodyLarge?.color,
                                            fontSize: 15,
                                          ),
                                        ),
                ),
                if (!isAudio) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.time,
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue : Colors.grey,
                        ),
                      ]
                    ],
                  ),
                ]
              ],
            ),
          ),

          if (isMe)
            const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, bool isMe) {
    Color textColor = isMe ? Colors.white : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    String fileName = message.filePath?.split('/').last ?? 'مستند';
    
    return GestureDetector(
      onTap: () {
        if (message.filePath != null && message.filePath!.startsWith('http')) {
          _launchURL(message.filePath!);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.insert_drive_file, color: isMe ? Colors.white : Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, bool isMe) {
    Color textColor = isMe ? Colors.white : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    return GestureDetector(
      onTap: () => _launchURL(message.text),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/map_placeholder.png', // This will fail if not exists, but we can use an icon instead
              width: 200,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 100,
                color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade200,
                child: Icon(Icons.map, size: 50, color: isMe ? Colors.white : Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: isMe ? Colors.white : Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                "الموقع الجغرافي",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, bool isMe) {
    Color textColor = isMe ? Colors.white : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    // Parse "جهة اتصال: Name \nرقم الهاتف: Phone"
    List<String> lines = message.text.split('\n');
    String name = lines[0].replaceAll('جهة اتصال:', '').trim();
    String phone = lines.length > 1 ? lines[1].replaceAll('رقم الهاتف:', '').trim() : '';

    return GestureDetector(
      onTap: () {
        if (phone.isNotEmpty) {
          _launchURL('tel:$phone');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: isMe ? Colors.white : Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isNotEmpty ? name : 'Contact',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (phone.isNotEmpty)
                Text(
                  phone,
                  style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool isLocal;
  final bool isMe;
  final String time;
  final bool isRead;
  
  const AudioPlayerWidget({
    super.key, 
    required this.url, 
    required this.isLocal, 
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with AutomaticKeepAliveClientMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  bool get wantKeepAlive => true; // يمنع إعادة بناء الويدجت وتدمير المشغل عند التمرير

  @override
  void initState() {
    super.initState();
    _initAudioListeners();
    _initSource(); // استدعاء فوري لجلب مدة المقطع (Duration) بدون تحميله بالكامل
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث مصدر الصوت إذا تغير الرابط أو الملف (مثل عند إرسال رسالة جديدة واستخدام نفس الـ State)
    if (oldWidget.url != widget.url || oldWidget.isLocal != widget.isLocal) {
      _isPlaying = false;
      _position = Duration.zero;
      _initSource();
    }
  }

  Future<void> _initSource() async {
    try {
      if (widget.isLocal) {
        await _audioPlayer.setFilePath(widget.url);
      } else {
        await _audioPlayer.setUrl(widget.url);
      }
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  void _initAudioListeners() {
    _audioPlayer.durationStream.listen((duration) {
      if(mounted && duration != null) setState(() => _duration = duration);
    });

    _audioPlayer.positionStream.listen((position) {
      if(mounted) setState(() => _position = position);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if(mounted) {
        setState(() {
          _isPlaying = state.playing;
          // تفعيل علامة التحميل فقط إذا كان يتم التجهيز الفعلي والمستخدم طلب التشغيل
          _isLoading = (state.processingState == ProcessingState.loading || state.processingState == ProcessingState.buffering) && state.playing;
          
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _position = Duration.zero;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.url.isEmpty) {
      return const SizedBox(
        width: 150,
        height: 40,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final textColor = widget.isMe ? Colors.white : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    final iconBgColor = widget.isMe ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final iconColor = widget.isMe ? Colors.white : Theme.of(context).colorScheme.primary;

    double maxDuration = _duration.inSeconds.toDouble();
    double currentPosition = _position.inSeconds.toDouble();
    if (maxDuration <= 0) maxDuration = 1.0;
    if (currentPosition > maxDuration) currentPosition = maxDuration;
    if (currentPosition < 0) currentPosition = 0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صورة الطبيب داخل الرسالة (زي واتساب)
          if (!widget.isMe) ...[
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 24, color: Colors.grey),
            ),
            const SizedBox(width: 8),
          ],
          
          // زر التشغيل
          GestureDetector(
            onTap: _togglePlay,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: iconBgColor,
              child: _isLoading
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: iconColor, strokeWidth: 2))
                  : Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: iconColor, size: 20),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // الشريط والوقت
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                    trackHeight: 3.0,
                  ),
                  child: Slider(
                    value: currentPosition,
                    max: maxDuration,
                    activeColor: textColor,
                    inactiveColor: textColor.withValues(alpha: 0.3),
                    onChanged: (value) {
                      setState(() {
                        _position = Duration(seconds: value.toInt());
                      });
                    },
                    onChangeEnd: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position.inSeconds > 0 ? _position : _duration),
                        style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 10),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.time,
                            style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 10),
                          ),
                          if (widget.isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              widget.isRead ? Icons.done_all : Icons.done,
                              size: 12,
                              color: widget.isRead ? Colors.blue : textColor.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final bool isNetwork;
  final String heroTag;

  const FullScreenImageScreen({
    super.key,
    required this.imagePath,
    required this.isNetwork,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: isNetwork
                ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.white),
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }
}

