part of 'cart_cubit.dart';

enum CartStatus { loading, ready, failure }

class CartState {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? message;

  const CartState({
    this.status = CartStatus.loading,
    this.items = const [],
    this.message,
  });

  int get itemsCount => items.length;

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  bool contains(int productId) =>
      items.any((item) => item.product.id == productId);

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? message,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }
}
