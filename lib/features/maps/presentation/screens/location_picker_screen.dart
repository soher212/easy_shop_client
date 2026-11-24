import 'package:easy_shop_client/core/services/reverse_geocoder.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/pick_location.dart';
import 'package:easy_shop_client/features/maps/domain/entities/picked_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;

  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _cairo = LatLng(30.0444, 31.2357);

  final _mapController = MapController();
  LatLng? _selected;
  String? _label;
  bool _isResolving = false;
  bool _isLocating = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) _select(initial);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _select(LatLng point) async {
    final requestId = ++_requestId;
    setState(() {
      _selected = point;
      _label = null;
      _isResolving = true;
    });
    final label = await ReverseGeocoder.labelFor(
      point.latitude,
      point.longitude,
    );
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _label = label;
      _isResolving = false;
    });
  }

  Future<void> _useMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    final position = await pickCurrentLocation(context);
    if (!mounted) return;
    setState(() => _isLocating = false);
    if (position == null) return;
    final point = LatLng(position.latitude, position.longitude);
    _mapController.move(point, 15);
    _select(point);
  }

  void _confirm() {
    final point = _selected!;
    Navigator.pop(
      context,
      PickedLocation(
        latitude: point.latitude,
        longitude: point.longitude,
        label: _label,
      ),
    );
  }

  String get _panelText {
    if (_selected == null) return 'Tap the map to choose the location';
    if (_isResolving) return 'Finding the place name...';
    return _label ??
        '${_selected!.latitude.toStringAsFixed(4)}, '
            '${_selected!.longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selected ?? _cairo,
              initialZoom: selected == null ? 11 : 15,
              onTap: (_, point) => _select(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.easy_shop_client',
              ),
              if (selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            right: AppDimensions.spaceMedium,
            top: AppDimensions.spaceMedium,
            child: FloatingActionButton.small(
              heroTag: 'my-location',
              backgroundColor: context.appColors.surface,
              onPressed: _useMyLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_panelText, style: AppTextStyles.body),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceMedium),
                    AppButton(
                      label: 'Confirm Location',
                      onPressed: selected == null ? null : _confirm,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
