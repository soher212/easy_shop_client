import 'package:bloc_test/bloc_test.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/domain/usecases/cart_usecases.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/cart/presentation/screens/cart_screen.dart';
import 'package:easy_shop_client/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCart extends Mock implements GetCartUseCase {}

class _MockAddToCart extends Mock implements AddToCartUseCase {}

class _MockRemoveFromCart extends Mock implements RemoveFromCartUseCase {}

class _MockGetFavorites extends Mock implements GetFavoritesUseCase {}

class _MockAddFavorite extends Mock implements AddFavoriteUseCase {}

class _MockRemoveFavorite extends Mock implements RemoveFavoriteUseCase {}

ProductEntity _product({int id = 1, double price = 150, int stock = 12}) {
  return ProductEntity(
    id: id,
    slug: 'p$id',
    name: 'Samsung A24',
    categoryId: 1,
    categoryName: 'Mobile Phone',
    price: price,
    stock: stock,
    merchantName: 'Elbatal Store',
    description: 'A nice phone.',
  );
}

void main() {
  late _MockGetCart getCart;
  late _MockAddToCart addToCart;
  late _MockRemoveFromCart removeFromCart;
  final phone = _product();

  setUpAll(() => registerFallbackValue(phone));

  setUp(() {
    getCart = _MockGetCart();
    addToCart = _MockAddToCart();
    removeFromCart = _MockRemoveFromCart();
    when(() => getCart()).thenAnswer((_) async => []);
    when(() => addToCart(any(), any())).thenAnswer((_) async {});
    when(() => removeFromCart(any())).thenAnswer((_) async {});
  });

  CartCubit buildCart() => CartCubit(getCart, addToCart, removeFromCart);

  Future<void> tapStepper(WidgetTester tester, IconData icon) async {
    final finder = find.byIcon(icon);
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  group('CartCubit', () {
    test('subtotal and count come from the lines', () {
      final state = CartState(
        status: CartStatus.ready,
        items: [
          CartItemEntity(product: _product(price: 150), quantity: 2),
          CartItemEntity(product: _product(id: 2, price: 25), quantity: 1),
        ],
      );
      expect(state.itemsCount, 2);
      expect(state.subtotal, 325);
      expect(state.contains(2), isTrue);
      expect(state.contains(9), isFalse);
    });

    blocTest<CartCubit, CartState>(
      'add reloads the cart and reports success',
      build: () {
        when(() => getCart()).thenAnswer(
          (_) async => [CartItemEntity(product: phone, quantity: 2)],
        );
        return buildCart();
      },
      act: (cubit) async {
        expect(await cubit.add(phone, 2), isTrue);
      },
      verify: (cubit) {
        expect(cubit.state.itemsCount, 1);
        verify(() => addToCart(any(), 2)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'a refused add reports failure with a message',
      build: () {
        when(() => addToCart(any(), any())).thenThrow(Exception('boom'));
        return buildCart();
      },
      act: (cubit) async {
        expect(await cubit.add(phone, 1), isFalse);
      },
      verify: (cubit) => expect(cubit.state.message, isNotNull),
    );

    blocTest<CartCubit, CartState>(
      'remove drops the line and puts it back when refused',
      build: () {
        when(() => getCart()).thenAnswer(
          (_) async => [CartItemEntity(product: phone, quantity: 1)],
        );
        when(() => removeFromCart(any())).thenThrow(Exception('boom'));
        return buildCart();
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.remove(1);
      },
      verify: (cubit) => expect(cubit.state.itemsCount, 1),
    );
  });

  group('CartScreen', () {
    Widget wrap(CartCubit cubit) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: CartScreen(onCheckout: () {}, onOpenProduct: (_) {}),
        ),
      ),
    );

    testWidgets('an empty cart says so and has no checkout button', (
      tester,
    ) async {
      final cubit = buildCart()..load();
      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsNothing);
    });

    testWidgets('shows the lines, the totals and the item count', (
      tester,
    ) async {
      when(() => getCart()).thenAnswer(
        (_) async => [
          CartItemEntity(product: phone, quantity: 2),
          CartItemEntity(product: _product(id: 2, price: 1000), quantity: 1),
        ],
      );
      final cubit = buildCart()..load();
      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('Qty: 2  ·  300 EGP'), findsOneWidget);
      expect(find.text('1,300 EGP'), findsNWidgets(2));
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });
  });

  group('ProductDetailsScreen', () {
    late CartCubit cart;
    late FavoritesCubit favorites;

    setUp(() {
      cart = buildCart();
      favorites = FavoritesCubit(
        _MockGetFavorites()..stub(),
        _MockAddFavorite(),
        _MockRemoveFavorite(),
      );
    });

    Widget wrap(ProductEntity product) => MaterialApp(
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cart),
          BlocProvider.value(value: favorites),
        ],
        child: ProductDetailsScreen(product: product),
      ),
    );

    testWidgets('quantity stays between 1 and the stock', (tester) async {
      await tester.pumpWidget(wrap(_product(stock: 2)));

      expect(find.text('12 units'), findsNothing);
      expect(find.text('2 units'), findsOneWidget);

      await tapStepper(tester, Icons.add);
      expect(find.text('2'), findsWidgets);
      await tapStepper(tester, Icons.add);
      expect(find.text('3'), findsNothing);

      await tapStepper(tester, Icons.remove);
      await tapStepper(tester, Icons.remove);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('add to cart sends the chosen quantity then confirms', (
      tester,
    ) async {
      when(
        () => getCart(),
      ).thenAnswer((_) async => [CartItemEntity(product: phone, quantity: 2)]);
      await tester.pumpWidget(wrap(phone));

      await tapStepper(tester, Icons.add);
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => addToCart(any(), 2)).called(1);
      expect(find.text('Added to Cart!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('an out of stock product cannot be added', (tester) async {
      await tester.pumpWidget(wrap(_product(stock: 0)));

      final button = find.widgetWithText(ElevatedButton, 'Out of Stock');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    });
  });
}

extension on _MockGetFavorites {
  void stub() => when(() => this()).thenAnswer((_) async => []);
}
