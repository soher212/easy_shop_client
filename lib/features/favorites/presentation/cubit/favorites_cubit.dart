import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final AddFavoriteUseCase _addFavorite;
  final RemoveFavoriteUseCase _removeFavorite;

  FavoritesCubit(this._getFavorites, this._addFavorite, this._removeFavorite)
    : super(const FavoritesState());

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      emit(
        FavoritesState(
          status: FavoritesStatus.ready,
          favorites: await _getFavorites(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  // The heart changes at once; it goes back if the server refuses.
  Future<void> toggle(ProductEntity product) async {
    final before = state.favorites;
    final wasFavorite = state.isFavorite(product.id);
    final after = wasFavorite
        ? before.where((item) => item.id != product.id).toList()
        : [...before, product];
    emit(state.copyWith(favorites: after));

    try {
      if (wasFavorite) {
        await _removeFavorite(product.id);
      } else {
        await _addFavorite(product);
      }
    } catch (error) {
      emit(
        state.copyWith(
          favorites: before,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }
}
