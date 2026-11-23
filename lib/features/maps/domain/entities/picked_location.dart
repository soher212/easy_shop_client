class PickedLocation {
  final double latitude;
  final double longitude;
  final String? label;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  });
}
