import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';

const String plasmaCatalogId = 'plasma:wallet_catalog:v1';

Catalog createPlasmaCatalog() {
  return Catalog(
    [
      CatalogItem(
        name: 'PlasmaWalletCard',
        dataSchema: S.object(), 
        widgetBuilder: (itemContext) {
          return const PlasmaWalletCard();
        },
      ),
    ],
    catalogId: plasmaCatalogId,
  );
}
