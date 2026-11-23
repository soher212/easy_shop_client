import 'package:easy_shop_client/core/widgets/app_image.dart';
import 'package:easy_shop_client/core/widgets/initials_avatar.dart';
import 'package:flutter/material.dart';

// The customer's photo, or their initials when they have not added one.
class ProfileAvatar extends StatelessWidget {
  final String initials;
  final String pictureUrl;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.initials,
    required this.size,
    this.pictureUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    if (pictureUrl.isEmpty) {
      return InitialsAvatar(initials: initials, size: size);
    }
    return AppImage(
      path: pictureUrl,
      size: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}
