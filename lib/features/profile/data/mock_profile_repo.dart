import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_form_data.dart';
import 'package:easy_shop_client/features/profile/domain/repositories/profile_repo.dart';

// Temporary: kept in memory until the server is back.
class MockProfileRepo implements ProfileRepo {
  ProfileEntity _profile = const ProfileEntity(
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phone: '+201000000000',
    address: '123 Tahrir Square, Cairo, Egypt',
    latitude: 30.0444,
    longitude: 31.2357,
  );

  @override
  Future<ProfileEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  @override
  Future<void> updateProfile(ProfileFormData data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _profile = ProfileEntity(
      name: data.name,
      email: data.email,
      phone: data.phone,
      address: data.address,
      latitude: data.latitude ?? _profile.latitude,
      longitude: data.longitude ?? _profile.longitude,
      pictureUrl: data.picture?.path ?? _profile.pictureUrl,
    );
  }
}
