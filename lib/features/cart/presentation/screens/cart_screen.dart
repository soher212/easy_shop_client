import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/empty_state.dart';
import 'package:easy_shop_client/core/widgets/error_view.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_summary_tile.dart';
import 'package:easy_shop_client/core/widgets/screen_title_bar.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onCheckout;
  final ValueChanged<ProductEntity> onOpenProduct;

  const CartScreen({
    super.key,
    required this.onCheckout,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state.itemsCount;
        return Column(
          children: [
            ScreenTitleBar(
              title: 'My Cart',
              trailing: count == 0
                  ? null
                  : '$count ${count == 1 ? 'item' : 'items'}',
            ),
            Expanded(child: _body(context, state)),
            if (state.items.isNotEmpty)
              _Summary(subtotal: state.subtotal, onCheckout: onCheckout),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, CartState state) {
    if (state.status == CartStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CartStatus.failure && state.items.isEmpty) {
      return ErrorView(
        message: state.message ?? 'Could not load your cart',
        onRetry: () => context.read<CartCubit>().load(),
      );
    }
    if (state.items.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add products to get started.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<CartCubit>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return ProductSummaryTile(
            product: item.product,
            imageSize: 76,
            onTap: () => onOpenProduct(item.product),
            footer: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Qty: ${item.quantity}  ·  ${formatEgp(item.lineTotal)}',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ),
            trailing: IconButton(
              tooltip: 'Remove',
              onPressed: () =>
                  context.read<CartCubit>().remove(item.product.id),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final double subtotal;
  final VoidCallback onCheckout;

  const _Summary({required this.subtotal, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(top: BorderSide(color: context.appColors.border)),
      ),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(label: 'Subtotal', value: formatEgp(subtotal)),
          const SizedBox(height: 10),
          _Row(label: 'Total', value: formatEgp(subtotal), isTotal: true),
          const SizedBox(height: AppDimensions.spaceMedium),
          AppButton(label: 'Proceed to Checkout', onPressed: onCheckout),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _Row({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.subtitle.copyWith(fontSize: 17)
              : AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                )
              : AppTextStyles.subtitle.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
