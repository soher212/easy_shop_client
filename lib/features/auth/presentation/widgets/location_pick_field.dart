import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

// The orange "pick on map" bar used by registration, profile and checkout.
class LocationPickField extends StatelessWidget {
  final String? label;
  final bool hasLocation;
  final String emptyText;
  final String doneSuffix;
  final VoidCallback onTap;

  const LocationPickField({
    super.key,
    required this.hasLocation,
    required this.onTap,
    this.label,
    this.emptyText = 'Location — tap to pick on map (optional)',
    this.doneSuffix = 'tap to change',
  });

  @override
  Widget build(BuildContext context) {
    final text = hasLocation
        ? '${label ?? 'Location set'} — $doneSuffix'
        : emptyText;
    return Material(
      color: context.appColors.primarySoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
