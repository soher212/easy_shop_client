import 'package:easy_shop_client/core/helpers/greeting.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/profile_avatar.dart';
import 'package:easy_shop_client/core/widgets/theme_mode_button.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// The white top part of Home: greeting, notifications, avatar and search.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: context.appColors.surface,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        topInset + AppDimensions.spaceMedium,
        AppDimensions.screenPadding,
        AppDimensions.spaceMedium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Greeting()),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const ThemeModeButton(),
              const SizedBox(width: 4),
              const _ProfileAvatar(),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          TextField(
            onChanged: context.read<HomeCubit>().search,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(
                Icons.search,
                color: context.appColors.textMuted,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = context.select<ProfileCubit, String?>(
      (cubit) => switch (cubit.state) {
        ProfileSuccess(:final profile) => profile.name,
        _ => null,
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greetingFor(DateTime.now()).toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          name == null ? 'Welcome 👋' : '$name 👋',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final profile = context.select<ProfileCubit, ProfileEntity?>(
      (cubit) => switch (cubit.state) {
        ProfileSuccess(:final profile) => profile,
        _ => null,
      },
    );
    return ProfileAvatar(
      initials: profile?.initials ?? '',
      pictureUrl: profile?.pictureUrl ?? '',
      size: 40,
    );
  }
}
