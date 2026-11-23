class ProfileEntity {
  final String name;
  final String email;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final String pictureUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.pictureUrl = '',
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasPicture => pictureUrl.isNotEmpty;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.toUpperCase();
  }

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}
