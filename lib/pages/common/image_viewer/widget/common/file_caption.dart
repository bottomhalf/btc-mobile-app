import 'package:conference/pages/common/textfield/bt_textfield.dart';
import 'package:conference/pages/common/voice_input/voice_input_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileCaption extends StatefulWidget {
  final Color bgColor;
  final bool buttonLoadingFlag;
  final Future<void> Function(String) upload;

  const FileCaption({
    super.key,
    required this.upload,
    required this.buttonLoadingFlag,
    this.bgColor = Colors.white,
  });

  @override
  State<FileCaption> createState() => _FileCaptionState();
}

class _FileCaptionState extends State<FileCaption> {
  late final TextEditingController captionController;

  @override
  void initState() {
    super.initState();
    captionController = TextEditingController();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: widget.bgColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Write image caption here",
          ),
          BtTextField.text(
            placeholder: "Type caption here...",
            controller: captionController,
            color: Colors.black,
            onValidate: (value) {
              return null;
            },
            onChange: (value) {},
            trailingIcon: IconButton(
              icon: const Icon(Icons.mic_rounded, color: Colors.blueAccent),
              onPressed: () async {
                final result = await Get.to(() => VoiceInputPage(
                      title: "Caption",
                      initialText: captionController.text,
                    ));
                if (result != null) {
                  captionController.text = result;
                }
              },
            ),
          ),
          Button(
            leadingIcon: Icons.upload,
            title: "Upload",
            onClick: () {
              FocusScope.of(context).unfocus();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.upload(captionController.text);
              });
            },
            isClicked: widget.buttonLoadingFlag,
          ),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final VoidCallback onClick;
  final bool isClicked;

  const Button({
    super.key,
    this.leadingIcon,
    required this.title,
    required this.onClick,
    this.isClicked = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isClicked ? null : onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B83EB), // Accent Purple from theme
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF7B83EB).withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isClicked
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

