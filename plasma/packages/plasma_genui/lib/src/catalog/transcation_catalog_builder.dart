import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';

class TranscationHistoryCatalogBuilder {
  static Widget catalogBuilder(CatalogItemContext itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawNumber = data['number'];
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
