import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

// The white title strip at the top of the tab screens (Favorites, Cart...).
class ScreenTitleBar extends StatelessWidget {
  final String title;
  final String? trailing;

  const ScreenTitleBar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        topInset + AppDimensions.spaceMedium,
        AppDimensions.screenPadding,
        AppDimensions.spaceMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.title),
          if (trailing != null)
            Text(
              trailing!,
              style: AppTextStyles.caption.copyWith(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
