import 'package:easy_shop_client/core/cache/cache_const.dart';
import 'package:easy_shop_client/core/cache/cache_helper.dart';
import 'package:easy_shop_client/core/di/dependency_injection.dart';
import 'package:easy_shop_client/core/routes/app_router.dart';
import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  setupGetIt();
  final token = await CacheHelper.getSecureData(key: CacheConstants.userToken);
  runApp(
    EasyShopApp(initialRoute: token != null ? Routes.home : Routes.splash),
  );
}

class EasyShopApp extends StatelessWidget {
  final String initialRoute;

  EasyShopApp({super.key, required this.initialRoute});

  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      // Only the requested screen: by default Flutter also stacks the "/"
      // route (our splash) underneath "/home", which brings it back on
      // "back" and breaks popping to the first route.
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
    );
  }
}
