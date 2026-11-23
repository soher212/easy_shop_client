part of 'profile_form_cubit.dart';

enum ProfileFormStatus { idle, submitting, saved, failure }

class ProfileFormState {
  final ProfileFormStatus status;
  final String? message;

  const ProfileFormState({this.status = ProfileFormStatus.idle, this.message});
}
