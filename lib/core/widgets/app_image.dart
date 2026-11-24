import 'dart:io';

import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Shows an image from the network, the app assets, or a file on the device.
// `size` is the height; the width defaults to the same value (a square).
class AppImage extends StatelessWidget {
  final String path;
  final double size;
  final double? width;
  final BorderRadius borderRadius;

  const AppImage({
    super.key,
    required this.path,
    required this.size,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  double get _width => width ?? size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: _image(context));
  }

  Widget _image(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: _width,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: _width, height: size, fit: BoxFit.cover);
    }
    return Image.file(
      File(path),
      width: _width,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: _width,
      height: size,
      color: context.appColors.neutralSoft,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: context.appColors.textMuted,
      ),
    );
  }
}
