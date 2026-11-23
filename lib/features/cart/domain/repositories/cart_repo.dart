import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

abstract class CartRepo {
  Future<List<CartItemEntity>> getCart();

  Future<void> addToCart(ProductEntity product, int quantity);

  Future<void> removeFromCart(int productId);
}
