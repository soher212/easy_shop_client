import 'package:easy_shop_client/core/helpers/validators.dart';
import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/core/widgets/app_text_field.dart';
import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:easy_shop_client/features/auth/presentation/widgets/avatar_picker.dart';
import 'package:easy_shop_client/features/auth/presentation/widgets/location_pick_field.dart';
import 'package:easy_shop_client/features/maps/presentation/pick_location_on_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  XFile? _picture;
  double? _latitude;
  double? _longitude;
  String? _locationLabel;

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
      _passwordController,
      _confirmController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await pickLocationOnMap(
      context,
      latitude: _latitude,
      longitude: _longitude,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
      _locationLabel = picked.label;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(
      RegisterData(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: Validators.normalizePhone(_phoneController.text),
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        picture: _picture,
        password: _passwordController.text,
      ),
    );
  }

  void _onState(BuildContext context, AuthState state) {
    if (state is AuthOtpSent) {
      Navigator.pushNamed(context, Routes.otp, arguments: state.email);
    } else if (state is AuthFailure) {
      showAppSnackBar(context, state.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: _onState,
          builder: (context, state) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: AvatarPicker(
                      picture: _picture,
                      onPicked: (file) => setState(() => _picture = file),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Full Name *',
                    hint: 'Ahmed Hassan',
                    controller: _nameController,
                    validator: Validators.fullName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Email *',
                    hint: 'ahmed@example.com',
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Phone *',
                    hint: '+20 100 000 0000',
                    controller: _phoneController,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Address',
                    hint: 'Street, City (optional)',
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall + 4),
                  LocationPickField(
                    hasLocation: _latitude != null && _longitude != null,
                    label: _locationLabel,
                    onTap: _pickLocation,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Password *',
                    hint: '••••••••',
                    controller: _passwordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                    isPassword: true,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Confirm Password *',
                    hint: '••••••••',
                    controller: _confirmController,
                    validator: Validators.confirmPassword(
                      () => _passwordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                    isPassword: true,
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  AppButton(
                    label: 'Create Account',
                    isLoading: state is AuthLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AuthSwitchPrompt(
                    prompt: 'Already have an account?',
                    action: 'Login',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, Routes.login),
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Text(
                    '* Required',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
