import 'package:flutter/material.dart';
import 'package:plasma_genui/plasma_genui.dart';

class PlasmaGenUiOverview extends StatelessWidget {
  const PlasmaGenUiOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Plasma GenUI',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          PlasmaGenUi(contentGeneratorType: ContentGeneratorType.firebase),
        ],
      ),
    );
  }
}
