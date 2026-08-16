import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:just_audio/just_audio.dart';

class ThemeColors {
  static const Color primary = Color(0xFF7B83EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
}


class VoiceInputPage extends StatefulWidget {
  final String title;
  final String initialText;

  const VoiceInputPage({
    super.key,
    required this.title,
    required this.initialText,
  });

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  
  // Animation for the pulsing mic button
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _initSpeech();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechToText.cancel();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      _isSpeechInitialized = await _speechToText.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing speech to text: $e");
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing sound $assetPath: $e");
    }
  }

  void _startListening() async {
    if (!_isSpeechInitialized) {
      _initSpeech();
      return;
    }

    await _playSound("assets/start-camera.mp3");
    
    setState(() {
      _isListening = true;
    });
    _animationController.repeat(reverse: true);

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          // Append or replace? Replaces for this speech snippet.
          // To make it look like "typing", we append the words to original text.
          if (result.recognizedWords.isNotEmpty) {
            final baseText = widget.initialText.trim();
            if (baseText.isEmpty) {
              _textController.text = result.recognizedWords;
            } else {
              _textController.text = "$baseText ${result.recognizedWords}";
            }
          }
        });
      },
      listenFor: const Duration(seconds: 60),
    );
  }

  void _stopListening() async {
    await _playSound("assets/beep-stop.mp3");
    
    setState(() {
      _isListening = false;
    });
    _animationController.stop();
    _animationController.reset();
    
    await _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: ThemeColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Voice input: ${widget.title}",
          style: const TextStyle(
            color: ThemeColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: _textController.text),
            child: const Text(
              "APPLY",
              style: TextStyle(
                color: ThemeColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Text View Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Your spoken text will appear here...",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: ThemeColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            
            // Microphone Control Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isListening ? "Listening..." : "Hold button and speak",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _isListening ? Colors.red : ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isListening ? "Release to stop recording" : "Press & hold the mic button to write",
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Pulse button
                  Center(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: GestureDetector(
                        onLongPress: _startListening,
                        onLongPressUp: _stopListening,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? Colors.red : ThemeColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? Colors.red : ThemeColors.primary).withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
