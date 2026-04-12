import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarWidget({super.key, required this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isFocused = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  Timer? _debounce;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop();

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) {
        setState(() => _isListening = false);
        _pulseController.stop();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _pulseController.stop();
        }
      },
    );
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _showSnack("Voice search not available on this device.");
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _pulseController.stop();
    } else {
      setState(() => _isListening = true);
      _pulseController.repeat(reverse: true);

      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          setState(() => _controller.text = words);
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: words.length),
          );
          // سيرش live مع كل كلمة تتعرف
          if (words.isNotEmpty) {
            _debounce?.cancel();
            widget.onSearch(words);
          }
          if (result.finalResult) {
            setState(() => _isListening = false);
            _pulseController.stop();
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF00965E),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value.trim());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isFocused || _isListening)
                ? const Color(0xFF00965E).withOpacity(0.18)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isFocused || _isListening ? 18 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: _onTextChanged,
        onSubmitted: (value) => widget.onSearch(value.trim()),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: _isListening ? "Listening..." : "Search for medicine or pharmacy...",
          hintStyle: TextStyle(
            color: _isListening
                ? const Color(0xFF00965E)
                : Colors.grey.shade500,
            fontSize: 14,
            fontWeight: _isListening ? FontWeight.w600 : FontWeight.w400,
          ),

          // 🔍 Search Icon
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isListening ? Icons.mic_rounded : Icons.search_rounded,
              key: ValueKey(_isListening),
              color: (_isFocused || _isListening)
                  ? const Color(0xFF00965E)
                  : Colors.grey.shade500,
              size: 22,
            ),
          ),

          // 🎙️ Mic / Send Button
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear button — يظهر لو في نص مكتوب
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _debounce?.cancel();
                    widget.onSearch(''); // مسح السيرش فوراً
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: Colors.grey),
                  ),
                ),

              // Mic Button
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.red
                        : const Color(0xFF00965E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isListening
                      ? AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) => Transform.scale(
                            scale: _pulseAnim.value,
                            child: const Icon(Icons.mic_rounded,
                                size: 16, color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.mic_rounded,
                          size: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          filled: true,
          fillColor: _isListening
              ? const Color(0xFFE8F5EE)
              : (_isFocused ? Colors.white : const Color(0xFFF5F7FA)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
                color: Color(0xFF00965E), width: 1.5),
          ),
        ),
      ),
    );
  }
}