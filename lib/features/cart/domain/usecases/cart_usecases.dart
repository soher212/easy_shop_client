import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/domain/repositories/cart_repo.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

class GetCartUseCase {
  final CartRepo _repo;

  GetCartUseCase(this._repo);

  Future<List<CartItemEntity>> call() => _repo.getCart();
}

class AddToCartUseCase {
  final CartRepo _repo;

  AddToCartUseCase(this._repo);

  Future<void> call(ProductEntity product, int quantity) {
    return _repo.addToCart(product, quantity);
  }
}

class RemoveFromCartUseCase {
  final CartRepo _repo;

  RemoveFromCartUseCase(this._repo);

  Future<void> call(int productId) => _repo.removeFromCart(productId);
}
