import 'package:easy_shop_client/features/profile/domain/entities/profile_form_data.dart';
import 'package:easy_shop_client/features/profile/domain/repositories/profile_repo.dart';

class UpdateProfileUseCase {
  final ProfileRepo _profileRepo;

  UpdateProfileUseCase(this._profileRepo);

  Future<void> call(ProfileFormData data) => _profileRepo.updateProfile(data);
}
