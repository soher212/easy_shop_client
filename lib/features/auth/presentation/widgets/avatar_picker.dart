import 'dart:io';

import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/widgets/dashed_border.dart';
import 'package:easy_shop_client/core/widgets/pick_image_sheet.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final XFile? picture;
  final ValueChanged<XFile> onPicked;

  const AvatarPicker({
    super.key,
    required this.picture,
    required this.onPicked,
  });

  static const _size = 88.0;

  Future<void> _pick(BuildContext context) async {
    final file = await pickImageFromSheet(context);
    if (file != null) onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: DashedBorder(
        radius: _size / 2,
        color: AppColors.primary.withValues(alpha: 0.6),
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.primarySoft,
            image: picture == null
                ? null
                : DecorationImage(
                    image: FileImage(File(picture!.path)),
                    fit: BoxFit.cover,
                  ),
          ),
          child: picture == null
              ? const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                )
              : null,
        ),
      ),
    );
  }
}
