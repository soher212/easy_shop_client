part of 'checkout_cubit.dart';

enum CheckoutStatus {
  idle,
  submitting,
  // The card order exists and its payment page is ready to open.
  awaitingPayment,
  // Order placed (and paid, for cards).
  placed,
  // The order exists but the card payment didn't go through.
  paymentFailed,
  // The order itself could not be placed.
  failure,
}

class CheckoutState {
  final CheckoutStatus status;
  final String? orderCode;
  final Uri? checkoutUri;
  final String? message;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.orderCode,
    this.checkoutUri,
    this.message,
  });
}
