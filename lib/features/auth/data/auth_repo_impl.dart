import 'package:easy_shop_client/core/cache/cache_const.dart';
import 'package:easy_shop_client/core/cache/cache_helper.dart';
import 'package:easy_shop_client/core/networking/api_constants.dart';
import 'package:easy_shop_client/core/networking/api_service.dart';
import 'package:easy_shop_client/features/auth/data/register_request_body.dart';
import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';
import 'package:easy_shop_client/features/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiService _apiService;

  AuthRepoImpl(this._apiService);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return response.data['message'];
  }

  @override
  Future<String> register(RegisterData data) async {
    final response = await _apiService.post(
      ApiConstants.register,
      data: await data.toFormData(),
    );
    return response.data['message'];
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _apiService.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp_code': otpCode},
    );
    await CacheHelper.saveSecureData(
      key: CacheConstants.userToken,
      value: response.data['token'],
    );
    return response.data['message'];
  }

  @override
  Future<String> resendOtp({required String email}) async {
    final response = await _apiService.post(
      ApiConstants.resendOtp,
      data: {'email': email},
    );
    return response.data['message'];
  }

  @override
  Future<String> logout() async {
    try {
      final response = await _apiService.post(ApiConstants.logout);
      return response.data['message'];
    } finally {
      await CacheHelper.deleteSecureData(key: CacheConstants.userToken);
    }
  }
}
