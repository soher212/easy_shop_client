import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/domain/repositories/orders_repo.dart';

class GetOrdersUseCase {
  final OrdersRepo _repo;

  GetOrdersUseCase(this._repo);

  Future<List<OrderEntity>> call() => _repo.getOrders();
}

class PlaceOrderUseCase {
  final OrdersRepo _repo;

  PlaceOrderUseCase(this._repo);

  Future<String> call(PlaceOrderData data) => _repo.placeOrder(data);
}
