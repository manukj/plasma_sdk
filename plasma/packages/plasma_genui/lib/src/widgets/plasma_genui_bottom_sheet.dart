import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:plasma_ui/plasma_ui.dart';

import '../cubit/genui_cubit.dart';
import '../cubit/genui_state.dart';
import '../models/chat_feed_item.dart';
import 'chat_input_field.dart';
import 'chat_message_bubble.dart';

class PlasmaGenUiBottomSheet extends StatefulWidget {
  const PlasmaGenUiBottomSheet({super.key});

  @override
  State<PlasmaGenUiBottomSheet> createState() => _PlasmaGenUiBottomSheetState();
}

class _PlasmaGenUiBottomSheetState extends State<PlasmaGenUiBottomSheet> {
  static const double _sheetHeightFactor = 0.9;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenUiCubit, GenUiState>(
      builder: (context, state) {
        final items = _getItems(state);
        final isLoading = state is GenUiLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: MediaQuery.of(context).size.height * _sheetHeightFactor,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: PlasmaTheme.primary,
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
              Divider(color: PlasmaTheme.primary.withValues(alpha: 0.2)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      final item = items[index];
                      if (item.isMessage && item.message != null) {
                        return ChatMessageBubble(message: item.message!);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GenUiSurface(
                          host: context.read<GenUiCubit>().host,
                          surfaceId: item.surfaceId!,
                        ),
                      );
                    }

                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: PlasmaLoadingWidget(
                        size: 48,
                        message: "Thinking...",
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    );
                  },
                ),
              ),
              ChatInputField(
                controller: _textController,
                isLoading: isLoading,
                onSend: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    context.read<GenUiCubit>().sendMessage(text);
                    _textController.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  List<PlasmaFeedItem> _getItems(GenUiState state) {
    return switch (state) {
      GenUiLoading() => state.items,
      GenUiMessageReceived() => state.items,
      GenUiSurfaceAdded() => state.items,
      GenUiError() => state.items,
      _ => [],
    };
  }
}
