import 'dart:io';

import 'package:easy_shop_client/core/helpers/validators.dart';
import 'package:easy_shop_client/core/services/reverse_geocoder.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/core/widgets/app_text_field.dart';
import 'package:easy_shop_client/core/widgets/pick_image_sheet.dart';
import 'package:easy_shop_client/core/widgets/profile_avatar.dart';
import 'package:easy_shop_client/features/auth/presentation/widgets/location_pick_field.dart';
import 'package:easy_shop_client/features/maps/presentation/pick_location_on_map.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_form_data.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late final _phoneController = TextEditingController(
    text: widget.profile.phone,
  );
  late final _addressController = TextEditingController(
    text: widget.profile.address,
  );

  late double? _latitude = widget.profile.latitude;
  late double? _longitude = widget.profile.longitude;
  String? _locationLabel;
  XFile? _picture;
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile.hasLocation) _loadLocationLabel();
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLocationLabel() async {
    final label = await ReverseGeocoder.labelFor(
      widget.profile.latitude!,
      widget.profile.longitude!,
    );
    if (mounted && _locationLabel == null) {
      setState(() => _locationLabel = label);
    }
  }

  Future<void> _changePhoto() async {
    final file = await pickImageFromSheet(context);
    if (file != null) {
      setState(() {
        _picture = file;
        _justSaved = false;
      });
    }
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
      _justSaved = false;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ProfileFormCubit>().submit(
      ProfileFormData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: Validators.normalizePhone(_phoneController.text),
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        picture: _picture,
      ),
    );
  }

  void _onState(BuildContext context, ProfileFormState state) {
    if (state.status == ProfileFormStatus.saved) {
      context.read<ProfileCubit>().load();
      setState(() => _justSaved = true);
    } else if (state.status == ProfileFormStatus.failure) {
      showAppSnackBar(
        context,
        state.message ?? 'Could not save your profile',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: BlocConsumer<ProfileFormCubit, ProfileFormState>(
          listener: _onState,
          builder: (context, state) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Form(
              key: _formKey,
              onChanged: () {
                if (_justSaved) setState(() => _justSaved = false);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _AvatarEditor(
                      picture: _picture,
                      profile: widget.profile,
                      onTap: _changePhoto,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Full Name',
                    hint: 'Ahmed Hassan',
                    controller: _nameController,
                    validator: Validators.fullName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Email',
                    hint: 'ahmed@example.com',
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Phone',
                    hint: '+20 100 000 0000',
                    controller: _phoneController,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppTextField(
                    label: 'Address',
                    hint: 'Street, City',
                    controller: _addressController,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall + 4),
                  LocationPickField(
                    hasLocation: _latitude != null && _longitude != null,
                    label: _locationLabel,
                    emptyText: 'Location — tap to set on map',
                    doneSuffix: 'tap to update on map',
                    onTap: _pickLocation,
                  ),
                  if (_justSaved) ...[
                    const SizedBox(height: AppDimensions.spaceMedium),
                    const _SavedBanner(),
                  ],
                  const SizedBox(height: AppDimensions.spaceMedium),
                  AppButton(
                    label: 'Save Changes',
                    isLoading: state.status == ProfileFormStatus.submitting,
                    onPressed: _submit,
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

class _AvatarEditor extends StatelessWidget {
  final XFile? picture;
  final ProfileEntity profile;
  final VoidCallback onTap;

  const _AvatarEditor({
    required this.picture,
    required this.profile,
    required this.onTap,
  });

  static const _size = 88.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _size + 8,
        height: _size + 8,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: picture == null
                  ? ProfileAvatar(
                      initials: profile.initials,
                      pictureUrl: profile.pictureUrl,
                      size: _size,
                    )
                  : CircleAvatar(
                      radius: _size / 2,
                      backgroundImage: FileImage(File(picture!.path)),
                    ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.appColors.surface,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedBanner extends StatelessWidget {
  const _SavedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.successSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.successSoft),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Profile saved successfully!',
            style: AppTextStyles.body.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
