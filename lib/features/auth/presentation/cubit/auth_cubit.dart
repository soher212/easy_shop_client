import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/auth/domain/entities/register_data.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._verifyOtpUseCase,
    this._resendOtpUseCase,
    this._logoutUseCase,
  ) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final message = await _loginUseCase(email: email, password: password);
      emit(AuthOtpSent(email: email, message: message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> register(RegisterData data) async {
    emit(AuthLoading());
    try {
      final message = await _registerUseCase(data);
      emit(AuthOtpSent(email: data.email, message: message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    emit(AuthLoading());
    try {
      await _verifyOtpUseCase(email: email, otpCode: otpCode);
      emit(AuthVerified());
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> resendOtp({required String email}) async {
    emit(AuthLoading());
    try {
      final message = await _resendOtpUseCase(email: email);
      emit(AuthOtpSent(email: email, message: message));
    } catch (error) {
      emit(AuthFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
    } catch (_) {
      // the token is deleted locally either way, so the user is logged out
    }
    emit(AuthLoggedOut());
  }
}
