import 'dart:math';

import 'package:easy_shop_client/features/cart/domain/repositories/cart_repo.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/domain/repositories/orders_repo.dart';

// Temporary: kept in memory until the server is back. Like the real server it
// empties the cart once an order is placed.
class MockOrdersRepo implements OrdersRepo {
  final CartRepo _cartRepo;
  final List<OrderEntity> _orders = [];

  MockOrdersRepo(this._cartRepo);

  static const _codeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  @override
  Future<List<OrderEntity>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_orders.reversed);
  }

  @override
  Future<String> placeOrder(PlaceOrderData data) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final random = Random();
    final code = List.generate(
      8,
      (_) => _codeChars[random.nextInt(_codeChars.length)],
    ).join();

    _orders.add(
      OrderEntity(
        code: code,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        itemsCount: data.items.length,
        paymentMethod: data.paymentMethod,
        total: data.total,
        address: data.address,
      ),
    );
    for (final item in data.items) {
      await _cartRepo.removeFromCart(item.product.id);
    }
    return code;
  }
}
