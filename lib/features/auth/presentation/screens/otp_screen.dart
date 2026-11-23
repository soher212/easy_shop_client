import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/auth/presentation/widgets/otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _otpLength = 6;

  final _otpController = TextEditingController();
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyOtp(
      email: widget.email,
      otpCode: _otpController.text,
    );
  }

  void _onState(BuildContext context, AuthState state) {
    if (state is AuthVerified) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.verified, (_) => false);
    } else if (state is AuthOtpSent) {
      _otpController.clear();
      setState(() => _resent = true);
    } else if (state is AuthFailure) {
      setState(() => _resent = false);
      showAppSnackBar(context, state.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _onState,
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spaceLarge),
                  const _BellIcon(),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Text.rich(
                    TextSpan(
                      text: 'Code sent to ',
                      style: AppTextStyles.caption.copyWith(fontSize: 14),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  OtpInput(controller: _otpController, length: _otpLength),
                  if (_resent) ...[
                    const SizedBox(height: AppDimensions.spaceMedium),
                    Text(
                      'OTP resent successfully!',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spaceLarge),
                  AppButton(
                    label: 'Verify OTP',
                    isLoading: isLoading,
                    onPressed: _otpController.text.length == _otpLength
                        ? _verify
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthCubit>().resendOtp(
                            email: widget.email,
                          ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BellIcon extends StatelessWidget {
  const _BellIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
