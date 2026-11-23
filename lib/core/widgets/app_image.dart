import 'dart:io';

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
    return ClipRRect(borderRadius: borderRadius, child: _image());
  }

  Widget _image() {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: _width,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
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
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: _width,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
