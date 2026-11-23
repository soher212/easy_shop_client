import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';

abstract class OrdersRepo {
  Future<List<OrderEntity>> getOrders();

  // Returns the new order's code.
  Future<String> placeOrder(PlaceOrderData data);
}
