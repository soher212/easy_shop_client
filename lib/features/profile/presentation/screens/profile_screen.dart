import 'package:easy_shop_client/core/services/reverse_geocoder.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/error_view.dart';
import 'package:easy_shop_client/core/widgets/profile_avatar.dart';
import 'package:easy_shop_client/core/widgets/screen_title_bar.dart';
import 'package:easy_shop_client/core/widgets/theme_mode_button.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<ProfileEntity> onEditProfile;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenFavorites;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onEditProfile,
    required this.onOpenOrders,
    required this.onOpenFavorites,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTitleBar(title: 'Profile'),
        Expanded(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => switch (state) {
              ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ProfileFailure(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<ProfileCubit>().load(),
              ),
              ProfileSuccess(:final profile) => RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().load(),
                child: _Content(
                  profile: profile,
                  onEditProfile: onEditProfile,
                  onOpenOrders: onOpenOrders,
                  onOpenFavorites: onOpenFavorites,
                  onLogout: onLogout,
                ),
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final ProfileEntity profile;
  final ValueChanged<ProfileEntity> onEditProfile;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenFavorites;
  final VoidCallback onLogout;

  const _Content({
    required this.profile,
    required this.onEditProfile,
    required this.onOpenOrders,
    required this.onOpenFavorites,
    required this.onLogout,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to shop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      children: [
        _UserCard(profile: profile),
        const SizedBox(height: AppDimensions.spaceSmall),
        const Align(alignment: Alignment.centerRight, child: ThemeModeButton()),
        const SizedBox(height: AppDimensions.spaceMedium),
        Material(
          color: context.appColors.surface,
          elevation: 2,
          shadowColor: context.appColors.shadow,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Personal Information',
                onTap: () => _showPersonalInfo(context),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Delivery Address',
                onTap: () => _showAddress(context),
              ),
              _MenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'My Orders',
                onTap: onOpenOrders,
              ),
              _MenuItem(
                icon: Icons.favorite_border_rounded,
                label: 'Favorites',
                onTap: onOpenFavorites,
              ),
              _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                showDivider: false,
                onTap: () => onEditProfile(profile),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMedium),
        Material(
          color: context.appColors.errorSoft,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _confirmLogout(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPersonalInfo(BuildContext context) {
    _showSheet(
      context,
      title: 'Personal Information',
      rows: [
        ('Full Name', profile.name),
        ('Email', profile.email),
        ('Phone', profile.phone),
      ],
    );
  }

  void _showAddress(BuildContext context) {
    _showSheet(
      context,
      title: 'Delivery Address',
      rows: [('Address', profile.address)],
      extra: profile.hasLocation
          ? _PlaceName(
              latitude: profile.latitude!,
              longitude: profile.longitude!,
            )
          : null,
    );
  }

  void _showSheet(
    BuildContext context, {
    required String title,
    required List<(String, String)> rows,
    Widget? extra,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
              const SizedBox(height: AppDimensions.spaceMedium),
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.caption),
                      Text(
                        value.isEmpty ? '—' : value,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ?extra,
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final ProfileEntity profile;

  const _UserCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      elevation: 2,
      shadowColor: context.appColors.shadow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProfileAvatar(
              initials: profile.initials,
              pictureUrl: profile.pictureUrl,
              size: 68,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(fontSize: 19),
                  ),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(fontSize: 14),
                  ),
                  if (profile.phone.isNotEmpty)
                    Text(
                      profile.phone,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: context.appColors.border))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Icon(
              Icons.chevron_right,
              color: context.appColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceName extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _PlaceName({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ReverseGeocoder.labelFor(latitude, longitude),
      builder: (context, snapshot) {
        final label =
            snapshot.data ??
            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location on map', style: AppTextStyles.caption),
            Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}
