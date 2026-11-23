import 'package:image_picker/image_picker.dart';

class RegisterData {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final XFile? picture;
  final String password;

  const RegisterData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.address = '',
    this.latitude,
    this.longitude,
    this.picture,
  });
}
