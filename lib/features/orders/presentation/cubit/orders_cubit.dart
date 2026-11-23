import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/domain/usecases/orders_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase _getOrders;

  OrdersCubit(this._getOrders) : super(OrdersLoading());

  Future<void> load() async {
    emit(OrdersLoading());
    try {
      emit(OrdersSuccess(await _getOrders()));
    } catch (error) {
      emit(OrdersFailure(ApiErrorHandler.getMessage(error)));
    }
  }
}
