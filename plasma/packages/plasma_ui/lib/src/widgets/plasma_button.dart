import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

class PlasmaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const PlasmaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: PlasmaTheme.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: PlasmaTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlasmaTheme.radiusLg),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: PlasmaTheme.iconLg,
                width: PlasmaTheme.iconLg,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: PlasmaTheme.spacingMd),
                    Icon(icon, size: PlasmaTheme.iconMd),
                  ],
                ],
              ),
      ),
    );
  }
}
