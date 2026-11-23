import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      OrderStatus.pending => (
        'Pending',
        const Color(0xFFA65F00),
        AppColors.warningLight,
      ),
      OrderStatus.processing => (
        'Processing',
        AppColors.info,
        AppColors.infoLight,
      ),
      OrderStatus.completed => (
        'Completed',
        AppColors.success,
        AppColors.successLight,
      ),
      OrderStatus.cancelled => (
        'Cancelled',
        AppColors.error,
        AppColors.errorLight,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
