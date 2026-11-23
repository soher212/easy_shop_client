import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/logo_backdrop.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LogoBackdrop(scale: 0.62),
        const SizedBox(height: AppDimensions.spaceMedium),
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 26)),
        const SizedBox(height: AppDimensions.spaceSmall / 2),
        Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 14)),
      ],
    );
  }
}
