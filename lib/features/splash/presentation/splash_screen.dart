import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/widgets/logo_backdrop.dart';
import 'package:easy_shop_client/core/widgets/theme_mode_button.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onTap;

  const SplashScreen({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.appColors.background, context.appColors.surface],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LogoBackdrop(), SizedBox(height: 28), _Dots()],
                ),
              ),
            ),
            const Positioned(top: 44, right: 16, child: ThemeModeButton()),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (_) => Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
