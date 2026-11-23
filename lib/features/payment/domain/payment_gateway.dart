import 'package:easy_shop_client/features/payment/domain/entities/payment_models.dart';

// What checkout needs from a card payment provider. Paymob is the only
// implementation today; the server's own payment endpoint could replace it.
abstract class PaymentGateway {
  // The page where the customer enters their card, ready to open in a WebView.
  Future<Uri> createCheckout({
    required String orderCode,
    required double amount,
    required BillingData billing,
  });

  // [redirectUrl] is where the provider sent the customer back to; null means
  // they closed the page without finishing.
  PaymentResult resultFromRedirect(String? redirectUrl);
}
