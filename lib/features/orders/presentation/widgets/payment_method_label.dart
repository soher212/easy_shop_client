import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';

class PaymentMethodLabel extends StatelessWidget {
  final PaymentMethod method;

  const PaymentMethodLabel(this.method, {super.key});

  @override
  Widget build(BuildContext context) {
    final isCard = method == PaymentMethod.card;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCard ? Icons.credit_card_outlined : Icons.payments_outlined,
          size: 15,
          color: AppColors.textGrey,
        ),
        const SizedBox(width: 4),
        Text(
          isCard ? 'Card' : 'Cash',
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
