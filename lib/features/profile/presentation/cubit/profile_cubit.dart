import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;

  ProfileCubit(this._getProfile) : super(ProfileLoading());

  Future<void> load() async {
    emit(ProfileLoading());
    try {
      emit(ProfileSuccess(await _getProfile()));
    } catch (error) {
      emit(ProfileFailure(ApiErrorHandler.getMessage(error)));
    }
  }
}
