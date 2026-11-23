part of 'favorites_cubit.dart';

enum FavoritesStatus { loading, ready, failure }

class FavoritesState {
  final FavoritesStatus status;
  final List<ProductEntity> favorites;
  final String? message;

  const FavoritesState({
    this.status = FavoritesStatus.loading,
    this.favorites = const [],
    this.message,
  });

  bool isFavorite(int productId) =>
      favorites.any((product) => product.id == productId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ProductEntity>? favorites,
    String? message,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      message: message,
    );
  }
}
