import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;
import 'package:plasma/plasma.dart';

class TranscationHistoryCatalogBuilder {
  static Widget catalogBuilder(
    BuildContext context,
    ComponentNode<ComponentImplementation> node,
    ComponentProps props,
    ChildWidgetBuilder buildChild,
  ) {
    final rawNumber = props.value('number');
    int number = 10;

    if (rawNumber is int) {
      number = rawNumber;
    } else if (rawNumber is num) {
      number = rawNumber.toInt();
    } else if (rawNumber is String) {
      number = int.tryParse(rawNumber) ?? 10;
    }

    if (number > 50) number = 30;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PlasmaTheme.primary),
      ),
      padding: const EdgeInsets.all(8),
      child: PlasmaTranscationHistory(number: number),
    );
  }

  static Schema catalogDataSchema() {
    return S.object(
      properties: {
        'number': S.integer(
          description:
              'Number of latest transactions to display. Defaults to 10.',
          minimum: 1,
          maximum: 50,
        ),
      },
    );
  }
}
