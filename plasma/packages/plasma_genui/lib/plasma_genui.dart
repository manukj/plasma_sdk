import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:flutter/foundation.dart';

import 'src/catalog/plasma_catalog.dart';
import 'src/config/genui_config.dart';
import 'src/cubit/genui_cubit.dart';
import 'src/providers/mock_content_generator.dart';
import 'src/widgets/plasma_genui_bottom_sheet.dart';
import 'src/widgets/plasma_genui_trigger.dart';

export 'src/cubit/genui_cubit.dart';
export 'src/cubit/genui_state.dart';
export 'src/models/chat_message.dart';
export 'src/widgets/chat_input_field.dart';
export 'src/widgets/chat_message_bubble.dart';
export 'src/widgets/plasma_genui_bottom_sheet.dart';
export 'src/widgets/plasma_genui_trigger.dart';

enum ContentGeneratorType { firebase, mock }

class PlasmaGenUi extends StatelessWidget {
  const PlasmaGenUi({
    super.key,
    this.contentGeneratorType = ContentGeneratorType.mock,
  });

  final ContentGeneratorType contentGeneratorType;

  Future<ContentGenerator> _createGenerator(Catalog catalog) async {
    if (contentGeneratorType == ContentGeneratorType.mock) {
      return MockContentGenerator();
    }

    if (!_supportsFirebaseAi) {
      debugPrint(
        'PlasmaGenUi: Firebase AI is not supported on this platform. Falling back to mock content generator.',
      );
      return MockContentGenerator();
    }

    try {
      return FirebaseAiContentGenerator(
        catalog: catalog,
        systemInstruction: PlasmaGenUiConfig.systemPrompt,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'PlasmaGenUi: Failed to initialize Firebase generator. Falling back to mock. Error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return MockContentGenerator();
    }
  }

  bool get _supportsFirebaseAi {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<void> _openChat(BuildContext context) async {
    final catalog = createPlasmaCatalog();
    final processor = A2uiMessageProcessor(catalogs: [catalog]);
    final generator = await _createGenerator(catalog);

    if (!context.mounted) {
      generator.dispose();
      return;
    }

    final cubit = GenUiCubit(
      generator: generator,
      processor: processor,
    );

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider<GenUiCubit>.value(
        value: cubit,
        child: const PlasmaGenUiBottomSheet(),
      ),
    ).whenComplete(() {
      cubit.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlasmaGenUiTrigger(
      onTap: () => _openChat(context),
    );
  }
}
