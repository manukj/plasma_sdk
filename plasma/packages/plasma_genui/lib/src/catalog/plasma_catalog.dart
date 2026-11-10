import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:plasma/plasma.dart';
import 'package:plasma_genui/src/catalog/payment_catalog_builder.dart';
import 'package:plasma_genui/src/catalog/transcation_catalog_builder.dart';

const String plasmaCatalogId = 'plasma:wallet_catalog:v1';

CatalogImplementation createPlasmaCatalog() {
  return CatalogImplementation(
    id: plasmaCatalogId,
    components: [
      ComponentImplementation(
        name: 'PlasmaWalletCard',
        schema: S.object(),
        builder: (context, node, props, buildChild) {
          return const PlasmaWalletCard();
        },
      ),
      ComponentImplementation(
        name: 'PlasmaTranscationHistory',
        schema: TranscationHistoryCatalogBuilder.catalogDataSchema(),
        builder: TranscationHistoryCatalogBuilder.catalogBuilder,
      ),
      ComponentImplementation(
        name: 'PaymentView',
        schema: PaymentCatalogBuilder.catalogDataSchema(),
        builder: PaymentCatalogBuilder.catalogBuilder,
      ),
    ],
  );
}
