import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final bool isOptional;

  const FieldLabel(this.label, {super.key, this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        children: [
          if (isOptional)
            const TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
