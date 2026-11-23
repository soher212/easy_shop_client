import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;
}
