import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';
import 'package:plasma_genui/src/catalog/payment_catalog_builder.dart';
import 'package:plasma_genui/src/catalog/transcation_catalog_builder.dart';

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
      CatalogItem(
        name: 'PlasmaTranscationHistory',
        dataSchema: TranscationHistoryCatalogBuilder.catalogDataSchema(),
        widgetBuilder: TranscationHistoryCatalogBuilder.catalogBuilder,
      ),
      CatalogItem(
        name: 'PaymentView',
        dataSchema: PaymentCatalogBuilder.catalogDataSchema(),
        widgetBuilder: PaymentCatalogBuilder.catalogBuilder,
      ),
    ],
    catalogId: plasmaCatalogId,
  );
}
