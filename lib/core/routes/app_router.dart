import 'package:easy_shop_client/core/di/dependency_injection.dart';
import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/verified_screen.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/screens/home_shell.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop_client/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (context) => SplashScreen(
            onTap: () => Navigator.pushReplacementNamed(context, Routes.login),
          ),
        );
      case Routes.login:
        return _withAuthCubit(const LoginScreen());
      case Routes.register:
        return _withAuthCubit(const RegisterScreen());
      case Routes.otp:
        final email = settings.arguments as String;
        return _withAuthCubit(OtpScreen(email: email));
      case Routes.verified:
        return MaterialPageRoute(builder: (_) => const VerifiedScreen());
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AuthCubit>()),
              BlocProvider(create: (_) => getIt<HomeCubit>()..load()),
              BlocProvider(create: (_) => getIt<FavoritesCubit>()..load()),
              BlocProvider(create: (_) => getIt<CartCubit>()..load()),
              BlocProvider(create: (_) => getIt<OrdersCubit>()..load()),
              BlocProvider(create: (_) => getIt<ProfileCubit>()..load()),
            ],
            child: const HomeShell(),
          ),
        );
      default:
        return null;
    }
  }

  MaterialPageRoute<dynamic> _withAuthCubit(Widget screen) {
    return MaterialPageRoute(
      builder: (_) =>
          BlocProvider(create: (_) => getIt<AuthCubit>(), child: screen),
    );
  }
}
