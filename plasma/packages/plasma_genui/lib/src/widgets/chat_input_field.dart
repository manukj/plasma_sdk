import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

/// Chat input field with send button
class ChatInputField extends StatefulWidget {
  final VoidCallback onSend;
  final TextEditingController controller;
  final bool isLoading;

  const ChatInputField({
    required this.onSend,
    required this.controller,
    required this.isLoading,
    super.key,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PlasmaTheme.spacingMd,
                vertical: PlasmaTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: PlasmaTheme.border),
                borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
              ),
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: 'What can I help with?...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => canSend ? widget.onSend() : null,
                enabled: !widget.isLoading,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: canSend ? PlasmaTheme.primary : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: canSend ? Colors.white : PlasmaTheme.textTertiary,
              ),
              onPressed: canSend ? widget.onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
