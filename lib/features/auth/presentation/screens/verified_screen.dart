import 'dart:async';

import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

// The welcome screen after a successful OTP: shows for a moment, then Home.
class VerifiedScreen extends StatefulWidget {
  final Duration delay;

  const VerifiedScreen({super.key, this.delay = const Duration(seconds: 2)});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.appColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.successBright,
                size: 44,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'Verified!',
              style: AppTextStyles.title.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppDimensions.spaceSmall / 2),
            Text(
              'Welcome to Easy Shop 🛍️',
              style: AppTextStyles.caption.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
