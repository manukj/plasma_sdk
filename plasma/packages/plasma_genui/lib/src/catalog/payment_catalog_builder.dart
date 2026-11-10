import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;
import 'package:plasma/plasma.dart';

class PaymentCatalogBuilder {
  static Widget catalogBuilder(
    BuildContext context,
    ComponentNode<ComponentImplementation> node,
    ComponentProps props,
    ChildWidgetBuilder buildChild,
  ) {
    final toAddress = _readOptionalString(props.value('toAddress'));
    final amount = _readOptionalString(props.value('amount'));

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
        'toAddress': _nullableString(
          'Optional recipient address or identifier to prefill in PaymentView.',
        ),
        'amount': _nullableString(
          'Optional amount to prefill in PaymentView.',
        ),
      },
    );
  }

  /// A string that may also be null, as the system prompt tells the model to
  /// pass a missing value. genui accepted a null; a2ui_core checks the type.
  static Schema _nullableString(String description) {
    return Schema.fromMap({
      'type': ['string', 'null'],
      'description': description,
    });
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
