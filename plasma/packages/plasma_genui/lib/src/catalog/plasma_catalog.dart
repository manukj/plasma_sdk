import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';

/// Creates the Plasma widget catalog for GenUI
/// Currently contains only PlasmaWalletCard for balance queries
Catalog createPlasmaCatalog() {
  return Catalog([
    // Balance widget
    CatalogItem(
      name: 'PlasmaWalletCard',
      dataSchema: S.object(), // Empty schema - widget is self-contained
      widgetBuilder: (itemContext) {
        return const PlasmaWalletCard();
      },
    ),
  ]);
}
