import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

import '../models/chat_message.dart';

/// Individual chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  final PlasmaMessage message;

  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? PlasmaTheme.primary
              : message.isError
                  ? Colors.red.shade50
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : message.isError
                    ? Colors.red.shade900
                    : PlasmaTheme.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
