import 'package:flutter/material.dart';
import 'package:plasma_ui/plasma_ui.dart';

class PlasmaLoadingWidget extends StatefulWidget {
  final String? message;
  final String? subtitle;
  final double? size;
  final CrossAxisAlignment crossAxisAlignment;

  const PlasmaLoadingWidget({
    super.key,
    this.message,
    this.subtitle,
    this.size,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<PlasmaLoadingWidget> createState() => _PlasmaLoadingWidgetState();
}

class _PlasmaLoadingWidgetState extends State<PlasmaLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        SizedBox(
          width: widget.size ?? PlasmaTheme.loadingIndicator,
          height: widget.size ?? PlasmaTheme.loadingIndicator,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: CustomPaint(painter: _LoadingRingPainter()),
              );
            },
          ),
        ),
        const SizedBox(height: PlasmaTheme.spacing2xl),
        Text(
          widget.message ?? 'Creating your secure wallet...',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: PlasmaTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: PlasmaTheme.spacingSm),
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PlasmaTheme.textTertiary,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _LoadingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Scale all values based on size (baseline is 120px - PlasmaTheme.loadingIndicator)
    final scale = size.width / 120.0;

    // Outer rings
    final outerPaint = Paint()
      ..color = PlasmaTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    canvas.drawCircle(center, radius * 0.9, outerPaint);
    canvas.drawCircle(center, radius * 0.7, outerPaint);

    // Main rotating square
    final squarePaint = Paint()
      ..color = PlasmaTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale;

    final squareSize = radius * 0.6;
    final rect = Rect.fromCenter(
      center: center,
      width: squareSize,
      height: squareSize,
    );

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        rect,
        Radius.circular(8 * scale),
      ));
    canvas.drawPath(path, squarePaint);

    // Center dot
    final dotPaint = Paint()
      ..color = PlasmaTheme.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
