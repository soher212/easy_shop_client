import 'package:easy_shop_client/features/maps/domain/entities/picked_location.dart';
import 'package:easy_shop_client/features/maps/presentation/screens/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Opens the map so the user can drop a pin; null when they go back.
Future<PickedLocation?> pickLocationOnMap(
  BuildContext context, {
  double? latitude,
  double? longitude,
}) {
  final initial = latitude == null || longitude == null
      ? null
      : LatLng(latitude, longitude);
  return Navigator.push<PickedLocation>(
    context,
    MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: initial)),
  );
}
