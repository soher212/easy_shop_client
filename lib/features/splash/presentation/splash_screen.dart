import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/widgets/logo_backdrop.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onTap;

  const SplashScreen({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEF7ED),
                Color(0xFFFFFCEC),
                Color(0xFFFFFEFA),
                Colors.white,
              ],
              stops: [0, 0.5, 0.85, 1],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoBackdrop(),
              const SizedBox(height: 28),
              const _Dots(),
            ],
          ),
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
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
