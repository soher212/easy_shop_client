import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_form_data.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  final UpdateProfileUseCase _updateProfile;

  ProfileFormCubit(this._updateProfile) : super(const ProfileFormState());

  Future<void> submit(ProfileFormData data) async {
    if (state.status == ProfileFormStatus.submitting) return;
    emit(const ProfileFormState(status: ProfileFormStatus.submitting));
    try {
      await _updateProfile(data);
      emit(const ProfileFormState(status: ProfileFormStatus.saved));
    } catch (error) {
      emit(
        ProfileFormState(
          status: ProfileFormStatus.failure,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }
}
