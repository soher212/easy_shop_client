import 'package:easy_shop_client/features/favorites/domain/repositories/favorites_repo.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

// Temporary: kept in memory until the server is back.
class MockFavoritesRepo implements FavoritesRepo {
  final List<ProductEntity> _favorites = [];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 150));

  @override
  Future<List<ProductEntity>> getFavorites() async {
    await _delay();
    return List.unmodifiable(_favorites);
  }

  @override
  Future<void> addFavorite(ProductEntity product) async {
    await _delay();
    if (_favorites.every((item) => item.id != product.id)) {
      _favorites.add(product);
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    await _delay();
    _favorites.removeWhere((item) => item.id == productId);
  }
}
