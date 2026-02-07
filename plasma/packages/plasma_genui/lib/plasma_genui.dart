import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';

import 'src/catalog/plasma_catalog.dart';
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

class PlasmaGenUi extends StatelessWidget {
  const PlasmaGenUi({super.key});

  void _openChat(BuildContext context) {
    final catalog = createPlasmaCatalog();
    final processor = A2uiMessageProcessor(catalogs: [catalog]);
    final generator = MockContentGenerator();

    final cubit = GenUiCubit(
      generator: generator,
      processor: processor,
    );

    showModalBottomSheet<void>(
      context: context,
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
