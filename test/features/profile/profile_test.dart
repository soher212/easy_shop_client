import 'package:bloc_test/bloc_test.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/features/profile/data/mock_profile_repo.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_form_data.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_form_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:easy_shop_client/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfile extends Mock implements GetProfileUseCase {}

class _MockUpdateProfile extends Mock implements UpdateProfileUseCase {}

class _FakeFormData extends Fake implements ProfileFormData {}

void main() {
  const profile = ProfileEntity(
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phone: '+201000000000',
    address: '123 Tahrir Square, Cairo, Egypt',
    latitude: 30.0444,
    longitude: 31.2357,
  );

  late _MockGetProfile getProfile;
  late _MockUpdateProfile updateProfile;

  setUpAll(() => registerFallbackValue(_FakeFormData()));

  setUp(() {
    getProfile = _MockGetProfile();
    updateProfile = _MockUpdateProfile();
    when(() => getProfile()).thenAnswer((_) async => profile);
    when(() => updateProfile(any())).thenAnswer((_) async {});
  });

  test('initials and first name come from the name', () {
    expect(profile.initials, 'AH');
    expect(profile.firstName, 'Ahmed');
    expect(const ProfileEntity(name: 'sara', email: 'a@b.co').initials, 'S');
  });

  test('the mock repo keeps the saved changes', () async {
    final repo = MockProfileRepo();
    await repo.updateProfile(
      const ProfileFormData(
        name: 'Lama Rifaai',
        email: 'lama@example.com',
        phone: '+201005432610',
        address: 'Giza',
      ),
    );
    final saved = await repo.getProfile();
    expect(saved.name, 'Lama Rifaai');
    expect(saved.address, 'Giza');
    expect(saved.latitude, isNotNull, reason: 'keeps the old location');
  });

  blocTest<ProfileCubit, ProfileState>(
    'load emits loading then the profile',
    build: () => ProfileCubit(getProfile),
    act: (cubit) => cubit.load(),
    expect: () => [isA<ProfileLoading>(), isA<ProfileSuccess>()],
  );

  blocTest<ProfileFormCubit, ProfileFormState>(
    'saving reports saved, and a refused save reports failure',
    build: () => ProfileFormCubit(updateProfile),
    act: (cubit) async {
      await cubit.submit(
        const ProfileFormData(name: 'A B', email: 'a@b.co', phone: '+20100'),
      );
      expect(cubit.state.status, ProfileFormStatus.saved);

      when(() => updateProfile(any())).thenThrow(Exception('boom'));
      await cubit.submit(
        const ProfileFormData(name: 'A B', email: 'a@b.co', phone: '+20100'),
      );
    },
    verify: (cubit) {
      expect(cubit.state.status, ProfileFormStatus.failure);
      expect(cubit.state.message, isNotNull);
    },
  );

  group('ProfileScreen', () {
    Widget wrap({
      ValueChanged<ProfileEntity>? onEdit,
      VoidCallback? onOrders,
      VoidCallback? onFavorites,
      VoidCallback? onLogout,
    }) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: BlocProvider(
          create: (_) => ProfileCubit(getProfile)..load(),
          child: ProfileScreen(
            onEditProfile: onEdit ?? (_) {},
            onOpenOrders: onOrders ?? () {},
            onOpenFavorites: onFavorites ?? () {},
            onLogout: onLogout ?? () {},
          ),
        ),
      ),
    );

    testWidgets('shows the customer and the menu', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Ahmed Hassan'), findsOneWidget);
      expect(find.text('ahmed@example.com'), findsOneWidget);
      expect(find.text('AH'), findsOneWidget);
      for (final label in [
        'Personal Information',
        'Delivery Address',
        'My Orders',
        'Favorites',
        'Edit Profile',
        'Logout',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('the menu opens the right places', (tester) async {
      var orders = 0;
      var favorites = 0;
      ProfileEntity? edited;
      await tester.pumpWidget(
        wrap(
          onOrders: () => orders++,
          onFavorites: () => favorites++,
          onEdit: (p) => edited = p,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Orders'));
      await tester.tap(find.text('Favorites'));
      await tester.tap(find.text('Edit Profile'));
      expect(orders, 1);
      expect(favorites, 1);
      expect(edited?.name, 'Ahmed Hassan');

      await tester.tap(find.text('Personal Information'));
      await tester.pumpAndSettle();
      expect(find.text('+201000000000'), findsWidgets);
    });

    testWidgets('logout asks first and only then logs out', (tester) async {
      var loggedOut = 0;
      await tester.pumpWidget(wrap(onLogout: () => loggedOut++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsOneWidget);
      expect(loggedOut, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(loggedOut, 0);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(loggedOut, 1);
    });
  });

  group('EditProfileScreen', () {
    Widget wrap() => MaterialApp(
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ProfileCubit(getProfile)),
          BlocProvider(create: (_) => ProfileFormCubit(updateProfile)),
        ],
        child: const EditProfileScreen(profile: profile),
      ),
    );

    testWidgets('prefills the form and saves with a success message', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final values = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((field) => field.controller.text)
          .toList();
      expect(values, contains('Ahmed Hassan'));
      expect(values, contains('+201000000000'));

      await tester.enterText(find.byType(TextFormField).first, 'Ahmed Ali');
      final save = find.widgetWithText(ElevatedButton, 'Save Changes');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      final sent =
          verify(() => updateProfile(captureAny())).captured.single
              as ProfileFormData;
      expect(sent.name, 'Ahmed Ali');
      expect(sent.latitude, 30.0444);
      expect(find.text('Profile saved successfully!'), findsOneWidget);
    });

    testWidgets('blocks a one-word name and does not save', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Ahmed');
      final save = find.widgetWithText(ElevatedButton, 'Save Changes');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.textContaining('full name'), findsOneWidget);
      verifyNever(() => updateProfile(any()));
    });
  });
}
