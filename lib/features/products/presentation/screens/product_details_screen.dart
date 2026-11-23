import 'dart:async';

import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_image.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _isAdding = false;
  bool _justAdded = false;
  Timer? _resetTimer;

  ProductEntity get _product => widget.product;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);
    final added = await context.read<CartCubit>().add(_product, _quantity);
    if (!mounted) return;
    setState(() {
      _isAdding = false;
      _justAdded = added;
    });
    if (!added) {
      showAppSnackBar(
        context,
        context.read<CartCubit>().state.message ?? 'Could not add to cart',
        isError: true,
      );
      return;
    }
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(product: _product),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    child: _Details(
                      product: _product,
                      quantity: _quantity,
                      onQuantityChanged: (value) =>
                          setState(() => _quantity = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _AddToCartBar(
            isOutOfStock: _product.isOutOfStock,
            isAdding: _isAdding,
            justAdded: _justAdded,
            onPressed: _addToCart,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProductEntity product;

  const _Header({required this.product});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.isFavorite(product.id),
    );
    return Stack(
      children: [
        ProductImage(product: product, height: 250 + topInset),
        Positioned(
          top: topInset + 10,
          left: 16,
          child: _RoundButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: topInset + 10,
          right: 16,
          child: _RoundButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.error : AppColors.textGrey,
            onTap: () => context.read<FavoritesCubit>().toggle(product),
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _Details({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            product.categoryName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall + 2),
        Text(product.name, style: AppTextStyles.title.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          formatEgp(product.price),
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        Row(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text('Sold by ', style: AppTextStyles.caption),
            Text(
              product.merchantName,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (product.description.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spaceMedium),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIPTION',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(product.description, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spaceMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _StockCard(product: product)),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Quantity', style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  QuantityStepper(
                    value: quantity,
                    max: product.isOutOfStock ? 1 : product.stock,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  final ProductEntity product;

  const _StockCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = !product.isOutOfStock;
    final color = inStock ? AppColors.success : AppColors.error;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: inStock ? AppColors.successSoft : AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            inStock ? 'In Stock' : 'Availability',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 2),
          Text(
            inStock ? '${product.stock} units' : 'Out of stock',
            style: AppTextStyles.subtitle.copyWith(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final bool isOutOfStock;
  final bool isAdding;
  final bool justAdded;
  final VoidCallback onPressed;

  const _AddToCartBar({
    required this.isOutOfStock,
    required this.isAdding,
    required this.justAdded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: SafeArea(
        top: false,
        child: justAdded
            ? Container(
                height: AppDimensions.buttonHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusButton,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Added to Cart!',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton.icon(
                onPressed: isOutOfStock || isAdding ? null : onPressed,
                icon: isAdding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                label: Text(isOutOfStock ? 'Out of Stock' : 'Add to Cart'),
              ),
      ),
    );
  }
}
