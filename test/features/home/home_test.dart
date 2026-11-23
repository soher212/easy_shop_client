import 'package:bloc_test/bloc_test.dart';
import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/features/categories/domain/entities/category_entity.dart';
import 'package:easy_shop_client/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:easy_shop_client/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop_client/features/products/data/mock_products_repo.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/domain/usecases/get_products_usecase.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProducts extends Mock implements GetProductsUseCase {}

class _MockGetCategories extends Mock implements GetCategoriesUseCase {}

class _MockGetFavorites extends Mock implements GetFavoritesUseCase {}

class _MockAddFavorite extends Mock implements AddFavoriteUseCase {}

class _MockRemoveFavorite extends Mock implements RemoveFavoriteUseCase {}

ProductEntity _product(int id, int categoryId, String name, {int stock = 5}) {
  return ProductEntity(
    id: id,
    slug: 'p$id',
    name: name,
    categoryId: categoryId,
    categoryName: 'Cat$categoryId',
    price: 100,
    stock: stock,
    merchantName: 'Shop',
  );
}

void main() {
  test('formatEgp groups thousands', () {
    expect(formatEgp(150), '150 EGP');
    expect(formatEgp(1200), '1,200 EGP');
    expect(formatEgp(1234567.5), '1,234,567.50 EGP');
  });

  group('HomeCubit', () {
    late _MockGetProducts getProducts;
    late _MockGetCategories getCategories;

    setUp(() {
      getProducts = _MockGetProducts();
      getCategories = _MockGetCategories();
      when(() => getProducts()).thenAnswer(
        (_) async => [
          _product(1, 1, 'Samsung A24'),
          _product(2, 1, 'iPhone 14'),
          _product(3, 2, 'Phone Case'),
        ],
      );
      when(() => getCategories()).thenAnswer(
        (_) async => const [
          CategoryEntity(id: 1, name: 'Phones'),
          CategoryEntity(id: 2, name: 'Covers'),
        ],
      );
    });

    blocTest<HomeCubit, HomeState>(
      'a category filters the products and All shows them again',
      build: () => HomeCubit(getProducts, getCategories),
      act: (cubit) async {
        await cubit.load();
        cubit.selectCategory(2);
        expect((cubit.state as HomeSuccess).visibleProducts.map((p) => p.id), [
          3,
        ]);
        cubit.selectCategory(null);
      },
      verify: (cubit) {
        expect((cubit.state as HomeSuccess).visibleProducts.length, 3);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'search combines with the selected category',
      build: () => HomeCubit(getProducts, getCategories),
      act: (cubit) async {
        await cubit.load();
        cubit.selectCategory(1);
        cubit.search('iphone');
      },
      verify: (cubit) {
        final state = cubit.state as HomeSuccess;
        expect(state.visibleProducts.map((p) => p.id), [2]);
        expect(state.selectedCategoryId, 1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'load fails with a message when the request throws',
      build: () {
        when(() => getProducts()).thenThrow(Exception('boom'));
        return HomeCubit(getProducts, getCategories);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<HomeLoading>(), isA<HomeFailure>()],
    );
  });

  group('FavoritesCubit', () {
    late _MockGetFavorites getFavorites;
    late _MockAddFavorite add;
    late _MockRemoveFavorite remove;
    final phone = _product(1, 1, 'Phone');

    setUpAll(() => registerFallbackValue(phone));

    setUp(() {
      getFavorites = _MockGetFavorites();
      add = _MockAddFavorite();
      remove = _MockRemoveFavorite();
      when(() => getFavorites()).thenAnswer((_) async => []);
      when(() => add(any())).thenAnswer((_) async {});
      when(() => remove(any())).thenAnswer((_) async {});
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'toggle adds then removes a favorite',
      build: () => FavoritesCubit(getFavorites, add, remove),
      act: (cubit) async {
        await cubit.load();
        await cubit.toggle(phone);
        expect(cubit.state.isFavorite(1), isTrue);
        await cubit.toggle(phone);
      },
      verify: (cubit) {
        expect(cubit.state.isFavorite(1), isFalse);
        verify(() => add(any())).called(1);
        verify(() => remove(1)).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'a refused favorite goes back to how it was',
      build: () {
        when(() => add(any())).thenThrow(Exception('boom'));
        return FavoritesCubit(getFavorites, add, remove);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.toggle(phone);
      },
      verify: (cubit) {
        expect(cubit.state.isFavorite(1), isFalse);
        expect(cubit.state.message, isNotNull);
      },
    );
  });

  group('ProductCard', () {
    Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: SizedBox(width: 175, height: 222, child: child)),
      ),
    );

    testWidgets('shows the product details and toggles the heart', (
      tester,
    ) async {
      var toggled = 0;
      await tester.pumpWidget(
        wrap(
          ProductCard(
            product: _product(1, 1, 'Samsung A24'),
            isFavorite: false,
            onToggleFavorite: () => toggled++,
          ),
        ),
      );

      expect(find.text('Samsung A24'), findsOneWidget);
      expect(find.text('100 EGP'), findsOneWidget);
      expect(find.text('by Shop'), findsOneWidget);
      expect(find.text('Out of Stock'), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(toggled, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('marks a product with no stock', (tester) async {
      await tester.pumpWidget(
        wrap(
          ProductCard(
            product: _product(7, 3, 'Dell XPS 15', stock: 0),
            isFavorite: true,
            onToggleFavorite: () {},
          ),
        ),
      );

      expect(find.text('Out of Stock'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  test('the sample data has an out of stock product like the design', () async {
    final products = await MockProductsRepo().getProducts();
    expect(products.length, 10);
    expect(products.where((p) => p.isOutOfStock).map((p) => p.name), [
      'Dell XPS 15',
    ]);
  });
}
