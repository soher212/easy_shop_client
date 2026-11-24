import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  static const _preferenceKey = 'client_dark_mode_enabled';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final enabled = preferences.getBool(_preferenceKey) ?? false;
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setDarkMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
