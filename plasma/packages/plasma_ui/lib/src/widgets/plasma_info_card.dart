import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

class PlasmaInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PlasmaInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlasmaTheme.spacingLg),
      decoration: BoxDecoration(
        color: PlasmaTheme.background,
        borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: PlasmaTheme.iconContainerSm,
            height: PlasmaTheme.iconContainerSm,
            decoration: BoxDecoration(
              color: PlasmaTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: PlasmaTheme.primary,
              size: PlasmaTheme.iconLg,
            ),
          ),
          const SizedBox(width: PlasmaTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PlasmaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: PlasmaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
