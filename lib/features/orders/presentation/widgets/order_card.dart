import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:easy_shop_client/features/orders/presentation/widgets/payment_method_label.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.code}',
                  style: AppTextStyles.subtitle.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                OrderStatusBadge(order.status),
              ],
            ),
            Text(
              formatShortDate(order.createdAt),
              style: AppTextStyles.caption.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${order.itemsCount} item(s)',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    PaymentMethodLabel(order.paymentMethod),
                  ],
                ),
                Text(
                  formatEgp(order.total),
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
