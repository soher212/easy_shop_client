import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';

enum OrderStatus { pending, processing, completed, cancelled }

enum PaymentMethod { cash, card }

class OrderEntity {
  final String code;
  final OrderStatus status;
  final DateTime createdAt;
  final int itemsCount;
  final PaymentMethod paymentMethod;
  final double total;
  final String address;

  const OrderEntity({
    required this.code,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
    required this.paymentMethod,
    required this.total,
    this.address = '',
  });
}

// What the customer sends when placing an order.
class PlaceOrderData {
  final List<CartItemEntity> items;
  final String address;
  final double? latitude;
  final double? longitude;
  final PaymentMethod paymentMethod;

  const PlaceOrderData({
    required this.items,
    required this.address,
    required this.paymentMethod,
    this.latitude,
    this.longitude,
  });

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
}
