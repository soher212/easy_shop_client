import 'package:image_picker/image_picker.dart';

class ProfileFormData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final XFile? picture;

  const ProfileFormData({
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
    this.latitude,
    this.longitude,
    this.picture,
  });
}
