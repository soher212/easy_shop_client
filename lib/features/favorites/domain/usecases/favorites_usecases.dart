import 'package:easy_shop_client/features/favorites/domain/repositories/favorites_repo.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

class GetFavoritesUseCase {
  final FavoritesRepo _repo;

  GetFavoritesUseCase(this._repo);

  Future<List<ProductEntity>> call() => _repo.getFavorites();
}

class AddFavoriteUseCase {
  final FavoritesRepo _repo;

  AddFavoriteUseCase(this._repo);

  Future<void> call(ProductEntity product) => _repo.addFavorite(product);
}

class RemoveFavoriteUseCase {
  final FavoritesRepo _repo;

  RemoveFavoriteUseCase(this._repo);

  Future<void> call(int productId) => _repo.removeFavorite(productId);
}
