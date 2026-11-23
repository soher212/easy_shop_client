import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

abstract class FavoritesRepo {
  Future<List<ProductEntity>> getFavorites();

  Future<void> addFavorite(ProductEntity product);

  Future<void> removeFavorite(int productId);
}
