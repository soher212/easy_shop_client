import 'package:easy_shop_client/features/auth/domain/repositories/auth_repo.dart';

class ResendOtpUseCase {
  final AuthRepo _authRepo;

  ResendOtpUseCase(this._authRepo);

  Future<String> call({required String email}) {
    return _authRepo.resendOtp(email: email);
  }
}
