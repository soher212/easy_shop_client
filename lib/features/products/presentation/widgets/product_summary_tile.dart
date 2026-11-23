import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_image.dart';
import 'package:flutter/material.dart';

// The white card with a product tile, its category, name and price. Favorites
// and Cart share it and add their own trailing button and extra lines.
class ProductSummaryTile extends StatelessWidget {
  final ProductEntity product;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  final double imageSize;

  const ProductSummaryTile({
    super.key,
    required this.product,
    this.trailing,
    this.footer,
    this.onTap,
    this.imageSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(
                product: product,
                height: imageSize,
                width: imageSize,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.categoryName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle,
                    ),
                    Text(
                      formatEgp(product.price),
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    ?footer,
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
