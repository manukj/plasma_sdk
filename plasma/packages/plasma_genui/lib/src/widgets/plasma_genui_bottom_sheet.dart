import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:plasma_ui/plasma_ui.dart';

import '../cubit/genui_cubit.dart';
import '../cubit/genui_state.dart';
import 'chat_input_field.dart';
import 'chat_message_bubble.dart';

/// Bottom sheet containing the GenUI chat interface
class PlasmaGenUiBottomSheet extends StatelessWidget {
  const PlasmaGenUiBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Chat messages and surfaces
          Expanded(
            child: BlocBuilder<GenUiCubit, GenUiState>(
              builder: (context, state) {
                final messages = _getMessages(state);
                final surfaceIds = _getSurfaceIds(state);
                final isLoading = state is GenUiLoading;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      messages.length + surfaceIds.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Messages
                    if (index < messages.length) {
                      return ChatMessageBubble(message: messages[index]);
                    }

                    // Surfaces
                    if (index < messages.length + surfaceIds.length) {
                      final surfaceIndex = index - messages.length;
                      final surfaceId = surfaceIds[surfaceIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GenUiSurface(
                          host: context.read<GenUiCubit>().host,
                          surfaceId: surfaceId,
                        ),
                      );
                    }

                    // Loading indicator
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: PlasmaLoadingWidget(
                        size: 48,
                        message: "Thinking...",
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input field
          BlocBuilder<GenUiCubit, GenUiState>(
            builder: (context, state) {
              return ChatInputField(
                controller: textController,
                isLoading: state is GenUiLoading,
                onSend: () {
                  final text = textController.text.trim();
                  if (text.isNotEmpty) {
                    context.read<GenUiCubit>().sendMessage(text);
                    textController.clear();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<dynamic> _getMessages(GenUiState state) {
    return switch (state) {
      GenUiLoading() => state.messages,
      GenUiMessageReceived() => state.messages,
      GenUiSurfaceAdded() => state.messages,
      GenUiError() => state.messages,
      _ => [],
    };
  }

  List<String> _getSurfaceIds(GenUiState state) {
    return switch (state) {
      GenUiLoading() => state.surfaceIds,
      GenUiMessageReceived() => state.surfaceIds,
      GenUiSurfaceAdded() => state.surfaceIds,
      GenUiError() => state.surfaceIds,
      _ => [],
    };
  }
}
