import 'package:bloc_test/bloc_test.dart';
import 'package:easy_shop_client/core/theme/app_theme.dart';
import 'package:easy_shop_client/features/cart/data/mock_cart_repo.dart';
import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/domain/usecases/cart_usecases.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop_client/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:easy_shop_client/features/checkout/presentation/widgets/delivery_map_preview.dart';
import 'package:easy_shop_client/features/orders/data/mock_orders_repo.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/domain/usecases/orders_usecases.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/orders/presentation/screens/orders_screen.dart';
import 'package:easy_shop_client/features/orders/presentation/widgets/order_card.dart';
import 'package:easy_shop_client/features/payment/data/paymob_service.dart';
import 'package:easy_shop_client/features/payment/domain/entities/payment_models.dart';
import 'package:easy_shop_client/features/payment/domain/payment_gateway.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlaceOrder extends Mock implements PlaceOrderUseCase {}

class _MockGetOrders extends Mock implements GetOrdersUseCase {}

class _MockGetCart extends Mock implements GetCartUseCase {}

class _MockAddToCart extends Mock implements AddToCartUseCase {}

class _MockRemoveFromCart extends Mock implements RemoveFromCartUseCase {}

class _FakePlaceOrderData extends Fake implements PlaceOrderData {}

class _MockGateway extends Mock implements PaymentGateway {}

class _FakeBilling extends Fake implements BillingData {}

ProductEntity _product(int id, double price) => ProductEntity(
  id: id,
  slug: 'p$id',
  name: 'Product $id',
  categoryId: 1,
  categoryName: 'Cat',
  price: price,
  stock: 10,
  merchantName: 'Shop',
);

void main() {
  final items = [
    CartItemEntity(product: _product(1, 150), quantity: 2),
    CartItemEntity(product: _product(2, 25), quantity: 1),
  ];

  setUpAll(() {
    registerFallbackValue(_FakePlaceOrderData());
    registerFallbackValue(_FakeBilling());
  });

  group('MockOrdersRepo', () {
    test('placing an order saves it and empties those cart lines', () async {
      final cart = MockCartRepo();
      final orders = MockOrdersRepo(cart);
      await cart.addToCart(_product(1, 150), 2);
      await cart.addToCart(_product(2, 25), 1);

      final code = await orders.placeOrder(
        PlaceOrderData(
          items: items,
          address: 'Cairo, Egypt',
          paymentMethod: PaymentMethod.card,
        ),
      );

      expect(code, matches(RegExp(r'^[A-Z0-9]{8}$')));
      expect(await cart.getCart(), isEmpty);
      final saved = (await orders.getOrders()).single;
      expect(saved.code, code);
      expect(saved.status, OrderStatus.pending);
      expect(saved.itemsCount, 2);
      expect(saved.total, 325);
      expect(saved.paymentMethod, PaymentMethod.card);
    });

    test('the newest order comes first', () async {
      final orders = MockOrdersRepo(MockCartRepo());
      final data = PlaceOrderData(
        items: items,
        address: 'A',
        paymentMethod: PaymentMethod.cash,
      );
      final first = await orders.placeOrder(data);
      final second = await orders.placeOrder(data);

      expect((await orders.getOrders()).map((o) => o.code), [second, first]);
    });
  });

  group('CheckoutCubit', () {
    late _MockPlaceOrder placeOrder;
    late _MockGateway gateway;
    const billing = BillingData(
      firstName: 'Ahmed',
      lastName: 'Hassan',
      email: 'a@b.co',
      phoneNumber: '+201000000000',
    );
    final uri = Uri.parse('https://pay.example/checkout');

    PlaceOrderData orderWith(PaymentMethod method) => PlaceOrderData(
      items: items,
      address: 'Cairo',
      latitude: 30,
      longitude: 31,
      paymentMethod: method,
    );

    setUp(() {
      placeOrder = _MockPlaceOrder();
      gateway = _MockGateway();
      when(() => placeOrder(any())).thenAnswer((_) async => 'ABC12345');
      when(
        () => gateway.createCheckout(
          orderCode: any(named: 'orderCode'),
          amount: any(named: 'amount'),
          billing: any(named: 'billing'),
        ),
      ).thenAnswer((_) async => uri);
    });

    CheckoutCubit build() => CheckoutCubit(placeOrder, gateway);

    blocTest<CheckoutCubit, CheckoutState>(
      'a cash order is placed without touching the card gateway',
      build: build,
      act: (cubit) => cubit.placeOrder(orderWith(PaymentMethod.cash), billing),
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.placed);
        expect(cubit.state.orderCode, 'ABC12345');
        verifyNever(
          () => gateway.createCheckout(
            orderCode: any(named: 'orderCode'),
            amount: any(named: 'amount'),
            billing: any(named: 'billing'),
          ),
        );
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a refused order reports failure with a message',
      build: () {
        when(() => placeOrder(any())).thenThrow(Exception('boom'));
        return build();
      },
      act: (cubit) => cubit.placeOrder(orderWith(PaymentMethod.cash), billing),
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.failure);
        expect(cubit.state.message, isNotNull);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a card order is placed first, then waits for the payment page',
      build: build,
      act: (cubit) => cubit.placeOrder(orderWith(PaymentMethod.card), billing),
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.awaitingPayment);
        expect(cubit.state.orderCode, 'ABC12345');
        expect(cubit.state.checkoutUri, uri);
        verify(
          () => gateway.createCheckout(
            orderCode: 'ABC12345',
            amount: 325,
            billing: billing,
          ),
        ).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a successful card payment ends placed',
      build: () {
        when(
          () => gateway.resultFromRedirect(any()),
        ).thenReturn(const PaymentResult(status: PaymentStatus.success));
        return build();
      },
      act: (cubit) async {
        await cubit.placeOrder(orderWith(PaymentMethod.card), billing);
        cubit.finishPayment('https://example.com/payment-result?success=true');
      },
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.placed);
        expect(cubit.state.orderCode, 'ABC12345');
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a closed payment page leaves the order pending',
      build: () {
        when(
          () => gateway.resultFromRedirect(any()),
        ).thenReturn(const PaymentResult(status: PaymentStatus.cancelled));
        return build();
      },
      act: (cubit) async {
        await cubit.placeOrder(orderWith(PaymentMethod.card), billing);
        cubit.finishPayment(null);
      },
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.paymentFailed);
        expect(cubit.state.orderCode, 'ABC12345');
        expect(cubit.state.message, contains('not completed'));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'if the payment page cannot be created the order is still kept',
      build: () {
        when(
          () => gateway.createCheckout(
            orderCode: any(named: 'orderCode'),
            amount: any(named: 'amount'),
            billing: any(named: 'billing'),
          ),
        ).thenThrow(Exception('boom'));
        return build();
      },
      act: (cubit) => cubit.placeOrder(orderWith(PaymentMethod.card), billing),
      verify: (cubit) {
        expect(cubit.state.status, CheckoutStatus.paymentFailed);
        expect(cubit.state.orderCode, 'ABC12345');
      },
    );
  });

  group('Paymob', () {
    final service = PaymobService();
    const base = PaymobService.redirectionUrl;

    test('reads the result from the redirect url', () {
      expect(
        service
            .resultFromRedirect('$base?success=true&pending=false&id=77')
            .status,
        PaymentStatus.success,
      );
      expect(
        service.resultFromRedirect('$base?success=true&id=77').transactionId,
        '77',
      );
      expect(
        service.resultFromRedirect('$base?success=false&pending=false').status,
        PaymentStatus.failed,
      );
      expect(
        service.resultFromRedirect('$base?pending=true').status,
        PaymentStatus.pending,
      );
    });

    test('a closed page or another url counts as cancelled', () {
      expect(service.resultFromRedirect(null).status, PaymentStatus.cancelled);
      expect(
        service.resultFromRedirect('https://other.site/?success=true').status,
        PaymentStatus.cancelled,
      );
    });

    test('billing data splits the name and fills missing fields', () {
      final full = BillingData.fromProfile(
        name: 'Ahmed Hassan Ali',
        email: 'a@b.co',
        phone: '+201000000000',
      );
      expect(full.firstName, 'Ahmed');
      expect(full.lastName, 'Hassan Ali');

      // Paymob rejects spaces and anything over 15 characters.
      final spaced = BillingData.fromProfile(
        name: 'Ahmed Hassan',
        email: 'a@b.co',
        phone: '+20 100 000 0000',
      );
      expect(spaced.phoneNumber, '+201000000000');
      expect(
        BillingData.fromProfile(
          name: 'A B',
          email: 'a@b.co',
          phone: '+20 100 000 0000 123',
        ).phoneNumber,
        'NA',
      );

      final empty = BillingData.fromProfile(name: '', email: '', phone: '');
      expect(empty.firstName, 'NA');
      expect(empty.lastName, 'NA');
      expect(empty.email, 'NA');
      expect(empty.phoneNumber, 'NA');
    });
  });

  group('CheckoutScreen', () {
    late _MockPlaceOrder placeOrder;
    late _MockGateway gateway;
    late CartCubit cart;
    late OrdersCubit orders;

    setUp(() {
      placeOrder = _MockPlaceOrder();
      gateway = _MockGateway();
      when(() => placeOrder(any())).thenAnswer((_) async => 'KCCI1KTO');
      final getCart = _MockGetCart();
      when(() => getCart()).thenAnswer((_) async => []);
      cart = CartCubit(getCart, _MockAddToCart(), _MockRemoveFromCart());
      final getOrders = _MockGetOrders();
      when(() => getOrders()).thenAnswer((_) async => []);
      orders = OrdersCubit(getOrders);
    });

    Future<void> openCheckout(
      WidgetTester tester, {
      String address = '123 Tahrir Square, Cairo, Egypt',
      double? latitude = 30.0444,
      double? longitude = 31.2357,
      VoidCallback? onViewOrders,
      VoidCallback? onContinue,
    }) async {
      // A phone-sized window so the whole list is built and tappable.
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => CheckoutCubit(placeOrder, gateway),
                          ),
                          BlocProvider.value(value: cart),
                          BlocProvider.value(value: orders),
                        ],
                        child: CheckoutScreen(
                          items: items,
                          initialAddress: address,
                          initialLatitude: latitude,
                          initialLongitude: longitude,
                          onViewOrders: onViewOrders ?? () {},
                          onContinueShopping: onContinue ?? () {},
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the address, the items and the totals', (tester) async {
      await openCheckout(tester);

      expect(find.text('123 Tahrir Square, Cairo, Egypt'), findsOneWidget);
      expect(find.text('Change Location'), findsOneWidget);
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Items (2)'), findsOneWidget);
      expect(find.text('325 EGP'), findsNWidgets(2));
    });

    testWidgets('cannot place an order without an address', (tester) async {
      await openCheckout(tester, address: '');

      expect(find.text('Pick Location'), findsOneWidget);
      final button = find.widgetWithText(ElevatedButton, 'Place Order');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    });

    testWidgets('a delivery address without a map location is not enough', (
      tester,
    ) async {
      await openCheckout(tester, latitude: null, longitude: null);

      expect(
        find.textContaining('Pick your delivery location'),
        findsOneWidget,
      );
      final button = find.widgetWithText(ElevatedButton, 'Place Order');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    });

    testWidgets('choosing cash without a location opens the map', (
      tester,
    ) async {
      await openCheckout(tester, latitude: null, longitude: null);

      await tester.tap(find.text('Credit / Debit Card'));
      await tester.pump();
      expect(find.text('Select Location'), findsNothing);

      await tester.tap(find.text('Cash on Delivery'));
      await tester.pumpAndSettle();
      expect(find.text('Select Location'), findsOneWidget);
    });

    testWidgets('the delivery card shows a map once there is a location', (
      tester,
    ) async {
      await openCheckout(tester);
      expect(find.byType(DeliveryMapPreview), findsOneWidget);
      expect(find.text('Tap to choose your location on the map'), findsNothing);
    });

    testWidgets('choosing card explains the Paymob page', (tester) async {
      await openCheckout(tester);

      expect(find.textContaining('Paymob'), findsNothing);
      await tester.tap(find.text('Credit / Debit Card'));
      await tester.pump();
      expect(find.textContaining("Paymob's page"), findsOneWidget);
    });

    testWidgets('a cash order sends the location, then shows success', (
      tester,
    ) async {
      var viewedOrders = false;
      await openCheckout(tester, onViewOrders: () => viewedOrders = true);

      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      final sent =
          verify(() => placeOrder(captureAny())).captured.single
              as PlaceOrderData;
      expect(sent.paymentMethod, PaymentMethod.cash);
      expect(sent.address, '123 Tahrir Square, Cairo, Egypt');
      expect(sent.latitude, 30.0444);
      expect(sent.longitude, 31.2357);
      expect(sent.total, 325);

      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.text('#KCCI1KTO'), findsOneWidget);

      await tester.tap(find.text('View Orders'));
      await tester.pumpAndSettle();
      expect(viewedOrders, isTrue);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('My Orders', () {
    testWidgets('an empty list says so', (tester) async {
      final getOrders = _MockGetOrders();
      when(() => getOrders()).thenAnswer((_) async => []);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: BlocProvider(
              create: (_) => OrdersCubit(getOrders)..load(),
              child: const OrdersScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('an order card shows the code, date, items and total', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OrderCard(
              order: OrderEntity(
                code: 'KCCI1KTO',
                status: OrderStatus.pending,
                createdAt: DateTime(2026, 8, 22),
                itemsCount: 1,
                paymentMethod: PaymentMethod.cash,
                total: 150,
              ),
            ),
          ),
        ),
      );

      expect(find.text('#KCCI1KTO'), findsOneWidget);
      expect(find.text('22 Aug 2026'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('1 item(s)'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('150 EGP'), findsOneWidget);
    });
  });
}
