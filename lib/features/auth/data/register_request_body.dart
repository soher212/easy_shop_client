import 'package:dio/dio.dart';
import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';

// The domain entity can't know about Dio, so the data layer adds the
// multipart body the register endpoint expects.
extension RegisterRequestBody on RegisterData {
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      if (address.isNotEmpty) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (picture != null)
        'picture': await MultipartFile.fromFile(
          picture!.path,
          filename: picture!.name,
        ),
    });
  }
}
