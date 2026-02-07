import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';

class PaymentCatalogBuilder {
  static Widget catalogBuilder(CatalogItemContext itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    final toAddress = _readOptionalString(data['toAddress']);
    final amount = _readOptionalString(data['amount']);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PlasmaTheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PaymentView(
        toAddress: toAddress,
        amount: amount,
        compact: true,
      ),
    );
  }

  static Schema catalogDataSchema() {
    return S.object(
      properties: {
        'toAddress': S.string(
          description:
              'Optional recipient address or identifier to prefill in PaymentView.',
        ),
        'amount': S.string(
          description: 'Optional amount to prefill in PaymentView.',
        ),
      },
    );
  }

  static String? _readOptionalString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static bool? _readOptionalBool(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}
