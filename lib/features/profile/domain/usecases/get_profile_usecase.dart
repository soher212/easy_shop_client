import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/domain/repositories/profile_repo.dart';

class GetProfileUseCase {
  final ProfileRepo _profileRepo;

  GetProfileUseCase(this._profileRepo);

  Future<ProfileEntity> call() => _profileRepo.getProfile();
}
