import 'package:easy_shop_client/core/constants/app_assets.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// The logo over a soft, feathered grey patch. The logo sits a little high so
// its green leaf stands out above the patch, as in the design.
// [scale] 1 is the splash size; smaller values shrink everything together.
class LogoBackdrop extends StatelessWidget {
  final double scale;

  const LogoBackdrop({super.key, this.scale = 1});

  static const _width = 240.0;
  static const _height = 180.0;
  static const _logoWidth = 195.0;
  static const _lift = 12.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width * scale,
      height: _height * scale,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FeatheredPatchPainter(
                context.appColors.neutralSoft.withValues(alpha: 0.75),
                scale,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -_lift * scale),
            child: Image.asset(AppAssets.logo, width: _logoWidth * scale),
          ),
        ],
      ),
    );
  }
}

class _FeatheredPatchPainter extends CustomPainter {
  final Color color;
  final double scale;

  const _FeatheredPatchPainter(this.color, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final inset = 16.0 * scale;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * scale);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FeatheredPatchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.scale != scale;
}
