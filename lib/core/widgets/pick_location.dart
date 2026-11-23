import 'package:easy_shop_client/core/helpers/location_helper.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/core/widgets/open_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Reads the device location; null when it can't, after telling the user why.
Future<Position?> pickCurrentLocation(BuildContext context) async {
  try {
    return await LocationHelper.getCurrentPosition();
  } on LocationFailure catch (failure) {
    if (!context.mounted) return null;
    if (failure == LocationFailure.deniedForever) {
      await showOpenSettingsDialog(
        context,
        title: 'Location is blocked',
        message: failure.message,
        openSettings: Geolocator.openAppSettings,
      );
    } else {
      showAppSnackBar(context, failure.message, isError: true);
    }
    return null;
  }
}
