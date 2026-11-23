import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';
import 'package:easy_shop_client/features/auth/domain/repositories/auth_repo.dart';

class RegisterUseCase {
  final AuthRepo _authRepo;

  RegisterUseCase(this._authRepo);

  // register only creates the account and does not send an OTP,
  // so we ask for one right away and return that message
  Future<String> call(RegisterData data) async {
    await _authRepo.register(data);
    return _authRepo.resendOtp(email: data.email);
  }
}
