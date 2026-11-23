import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/domain/repositories/cart_repo.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

// Temporary: kept in memory until the server is back.
class MockCartRepo implements CartRepo {
  final List<CartItemEntity> _items = [];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 200));

  @override
  Future<List<CartItemEntity>> getCart() async {
    await _delay();
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addToCart(ProductEntity product, int quantity) async {
    await _delay();
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _items.add(CartItemEntity(product: product, quantity: quantity));
    } else {
      final total = _items[index].quantity + quantity;
      _items[index] = CartItemEntity(
        product: product,
        quantity: total > product.stock ? product.stock : total,
      );
    }
  }

  @override
  Future<void> removeFromCart(int productId) async {
    await _delay();
    _items.removeWhere((item) => item.product.id == productId);
  }
}
