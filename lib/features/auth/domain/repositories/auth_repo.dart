import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';

abstract class AuthRepo {
  Future<String> login({required String email, required String password});

  Future<String> register(RegisterData data);

  Future<String> verifyOtp({required String email, required String otpCode});

  Future<String> resendOtp({required String email});

  Future<String> logout();
}
