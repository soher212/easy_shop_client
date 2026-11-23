import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/orders/domain/usecases/orders_usecases.dart';
import 'package:easy_shop_client/features/payment/data/paymob_exception.dart';
import 'package:easy_shop_client/features/payment/domain/entities/payment_models.dart';
import 'package:easy_shop_client/features/payment/domain/payment_gateway.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrderUseCase _placeOrder;
  final PaymentGateway _gateway;

  CheckoutCubit(this._placeOrder, this._gateway) : super(const CheckoutState());

  bool get _isBusy =>
      state.status == CheckoutStatus.submitting ||
      state.status == CheckoutStatus.awaitingPayment;

  // Cash: the order is the end. Card: the order is placed first, then the
  // customer pays; if paying fails the order stays pending.
  Future<void> placeOrder(PlaceOrderData data, BillingData billing) async {
    if (_isBusy) return;
    emit(const CheckoutState(status: CheckoutStatus.submitting));

    final String code;
    try {
      code = await _placeOrder(data);
    } catch (error) {
      emit(
        CheckoutState(
          status: CheckoutStatus.failure,
          message: ApiErrorHandler.getMessage(error),
        ),
      );
      return;
    }

    if (data.paymentMethod == PaymentMethod.cash) {
      emit(CheckoutState(status: CheckoutStatus.placed, orderCode: code));
      return;
    }

    try {
      final uri = await _gateway.createCheckout(
        orderCode: code,
        amount: data.total,
        billing: billing,
      );
      emit(
        CheckoutState(
          status: CheckoutStatus.awaitingPayment,
          orderCode: code,
          checkoutUri: uri,
        ),
      );
    } catch (error) {
      emit(
        CheckoutState(
          status: CheckoutStatus.paymentFailed,
          orderCode: code,
          message: error is PaymobException
              ? 'Could not open the card payment page.'
              : ApiErrorHandler.getMessage(error),
        ),
      );
    }
  }

  // Called with where the payment page sent the customer, or null if they
  // closed it.
  void finishPayment(String? redirectUrl) {
    final code = state.orderCode;
    final result = _gateway.resultFromRedirect(redirectUrl);
    if (result.isSuccess) {
      emit(CheckoutState(status: CheckoutStatus.placed, orderCode: code));
      return;
    }
    emit(
      CheckoutState(
        status: CheckoutStatus.paymentFailed,
        orderCode: code,
        message: switch (result.status) {
          PaymentStatus.pending => 'Your payment is still being processed.',
          PaymentStatus.cancelled => 'The payment was not completed.',
          _ => 'The payment was declined.',
        },
      ),
    );
  }
}
