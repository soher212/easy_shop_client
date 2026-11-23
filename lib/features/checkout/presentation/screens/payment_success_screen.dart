import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderCode;
  final VoidCallback onViewOrders;
  final VoidCallback onContinueShopping;

  const PaymentSuccessScreen({
    super.key,
    required this.orderCode,
    required this.onViewOrders,
    required this.onContinueShopping,
  });

  // Back to the tabs first, then let the tabs switch to where the user chose.
  void _leave(BuildContext context, VoidCallback then) {
    Navigator.popUntil(context, (route) => route.isFirst);
    then();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context, onContinueShopping);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.successSoft, AppColors.surface],
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.screenPadding + 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.successBright,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              Text(
                'Payment Successful!',
                style: AppTextStyles.title.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.',
                style: AppTextStyles.caption.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '#$orderCode',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLarge + 8),
              ElevatedButton.icon(
                onPressed: () => _leave(context, onViewOrders),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('View Orders'),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusButton,
                  ),
                  onTap: () => _leave(context, onContinueShopping),
                  child: Container(
                    height: AppDimensions.buttonHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
