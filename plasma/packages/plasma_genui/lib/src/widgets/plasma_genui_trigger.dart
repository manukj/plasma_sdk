import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

class PlasmaGenUiTrigger extends StatelessWidget {
  final VoidCallback onTap;

  const PlasmaGenUiTrigger({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PlasmaTheme.spacingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PlasmaTheme.radiusMd),
          color: Colors.white,
          border: Border.all(
            color: PlasmaTheme.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: PlasmaTheme.textSecondary),
                SizedBox(width: PlasmaTheme.spacingSm),
                Text(
                  'How can I help you today?',
                  style: TextStyle(
                    color: PlasmaTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: PlasmaTheme.textTertiary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
