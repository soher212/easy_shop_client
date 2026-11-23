part of 'profile_cubit.dart';

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final ProfileEntity profile;

  ProfileSuccess(this.profile);
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(this.message);
}
