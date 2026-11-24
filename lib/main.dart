import 'package:easy_shop_client/core/cache/cache_const.dart';
import 'package:easy_shop_client/core/cache/cache_helper.dart';
import 'package:easy_shop_client/core/di/dependency_injection.dart';
import 'package:easy_shop_client/core/routes/app_router.dart';
import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  setupGetIt();
  final themeCubit = ThemeCubit();
  await themeCubit.load();
  final token = await CacheHelper.getSecureData(key: CacheConstants.userToken);
  runApp(
    EasyShopApp(
      initialRoute: token != null ? Routes.home : Routes.splash,
      themeCubit: themeCubit,
    ),
  );
}

class EasyShopApp extends StatelessWidget {
  final String initialRoute;
  final ThemeCubit? themeCubit;

  EasyShopApp({super.key, required this.initialRoute, this.themeCubit});

  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => themeCubit ?? ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          title: 'Easy Shop',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          initialRoute: initialRoute,
          // Only the requested screen: Flutter otherwise stacks the splash
          // below the initial route and may return to it when navigating back.
          onGenerateInitialRoutes: (name) => [
            _router.generateRoute(RouteSettings(name: name))!,
          ],
          onGenerateRoute: _router.generateRoute,
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Page not found')),
              body: const Center(child: Text("We couldn't find that page.")),
            ),
          ),
        ),
      ),
    );
  }
}
