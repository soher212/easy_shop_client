import 'package:easy_shop_client/core/widgets/app_image.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

// The product photo, or a coloured tile with a category icon when it has none.
class ProductImage extends StatelessWidget {
  final ProductEntity product;
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const ProductImage({
    super.key,
    required this.product,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = BorderRadius.zero,
  });

  static const _gradients = [
    [Color(0xFF4F9BFF), Color(0xFF5B5FFF)],
    [Color(0xFFC8D3E0), Color(0xFF7F90A8)],
    [Color(0xFFFF8A3D), Color(0xFFFF6B4A)],
    [Color(0xFFC77DFF), Color(0xFFF0389C)],
    [Color(0xFF00D1C1), Color(0xFF00A7D6)],
    [Color(0xFF8DA2C0), Color(0xFF5D7191)],
    [Color(0xFF2E5BD6), Color(0xFF1B3A9A)],
    [Color(0xFFF5F5F7), Color(0xFFD8DCE2)],
    [Color(0xFF12C79B), Color(0xFF0E9F77)],
    [Color(0xFFFFB400), Color(0xFFFF8A00)],
  ];

  IconData get _icon {
    final category = product.categoryName.toLowerCase();
    if (category.contains('cover') || category.contains('case')) {
      return Icons.shield_outlined;
    }
    if (category.contains('phone')) return Icons.smartphone;
    if (category.contains('laptop')) return Icons.laptop_mac;
    if (category.contains('audio')) return Icons.headphones;
    if (category.contains('accessor')) return Icons.usb;
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (product.imagePath.isNotEmpty) {
      return AppImage(
        path: product.imagePath,
        size: height,
        width: width,
        borderRadius: borderRadius,
      );
    }
    final colors = _gradients[(product.id - 1).abs() % _gradients.length];
    final isLight = colors.first.computeLuminance() > 0.8;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Icon(
          _icon,
          size: height * 0.42,
          color: isLight ? Colors.black38 : Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
