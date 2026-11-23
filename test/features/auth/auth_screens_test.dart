import 'package:bloc_test/bloc_test.dart';
import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/login_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/otp_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/register_screen.dart';
import 'package:easy_shop_client/features/auth/presentation/screens/verified_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit cubit;

  setUp(() {
    cubit = _MockAuthCubit();
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
  });

  Widget wrap(Widget screen) => MaterialApp(
    theme: AppTheme.light,
    home: BlocProvider<AuthCubit>.value(value: cubit, child: screen),
  );

  testWidgets('login validates before calling the server', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    verifyNever(
      () => cubit.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    when(
      () => cubit.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    await tester.tap(find.text('Login'));
    await tester.pump();

    verify(() => cubit.login(email: 'a@b.co', password: '123456')).called(1);
  });

  testWidgets('register blocks a one-word name and a bad phone', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const RegisterScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Ahmed');
    await tester.enterText(find.byType(TextFormField).at(2), '0100');
    final create = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pump();

    expect(find.textContaining('full name'), findsOneWidget);
    expect(find.textContaining('+20'), findsWidgets);
  });

  testWidgets('verify stays disabled until all six digits are typed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const OtpScreen(email: 'a@b.co')));

    final verify = find.widgetWithText(ElevatedButton, 'Verify OTP');
    expect(tester.widget<ElevatedButton>(verify).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(verify).onPressed, isNotNull);
  });

  testWidgets('the verified screen moves on to home after its delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => settings.name == Routes.home
              ? const Scaffold(body: Text('home reached'))
              : const VerifiedScreen(delay: Duration(milliseconds: 100)),
        ),
      ),
    );
    expect(find.text('Verified!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('home reached'), findsOneWidget);
  });
}
