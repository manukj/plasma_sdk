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
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controllerListener = () => setState(() {});
    widget.controller.addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(covariant ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerListener);
      widget.controller.addListener(_controllerListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.isLoading;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(PlasmaTheme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
            color: Colors.white,
            border: Border.all(
              color: PlasmaTheme.primary.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: PlasmaTheme.textSecondary,
              ),
              const SizedBox(width: PlasmaTheme.spacingSm),
              Expanded(
                child: TextField(
                  maxLines: null,
                  minLines: 1,
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => canSend ? widget.onSend() : null,
                  decoration: const InputDecoration(
                    hintText: 'How can I help you today?',
                    hintStyle: TextStyle(
                      color: PlasmaTheme.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: PlasmaTheme.spacingSm),
              GestureDetector(
                onTap: canSend ? widget.onSend : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: canSend ? PlasmaTheme.primary : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: canSend ? Colors.white : PlasmaTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
