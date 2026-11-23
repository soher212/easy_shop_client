import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/domain/usecases/cart_usecases.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;

  CartCubit(this._getCart, this._addToCart, this._removeFromCart)
    : super(const CartState());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      emit(CartState(status: CartStatus.ready, items: await _getCart()));
    } catch (error) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  // True when the product is now in the cart.
  Future<bool> add(ProductEntity product, int quantity) async {
    try {
      await _addToCart(product, quantity);
      emit(CartState(status: CartStatus.ready, items: await _getCart()));
      return true;
    } catch (error) {
      emit(state.copyWith(message: ApiErrorHandler.getMessage(error)));
      return false;
    }
  }

  // The line disappears at once; it comes back if the server refuses.
  Future<void> remove(int productId) async {
    final before = state.items;
    emit(
      state.copyWith(
        items: before.where((item) => item.product.id != productId).toList(),
      ),
    );
    try {
      await _removeFromCart(productId);
    } catch (error) {
      emit(
        state.copyWith(
          items: before,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }
}
