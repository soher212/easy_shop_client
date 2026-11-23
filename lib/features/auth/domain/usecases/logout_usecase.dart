import 'package:easy_shop_client/features/auth/domain/repositories/auth_repo.dart';

class LogoutUseCase {
  final AuthRepo _authRepo;

  LogoutUseCase(this._authRepo);

  Future<String> call() => _authRepo.logout();
}
