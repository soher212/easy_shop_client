import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AuthSwitchPrompt extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$prompt ', style: AppTextStyles.caption.copyWith(fontSize: 14)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
