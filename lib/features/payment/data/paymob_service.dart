import 'package:dio/dio.dart';
import 'package:easy_shop_client/features/payment/data/paymob_exception.dart';
import 'package:easy_shop_client/features/payment/domain/entities/payment_models.dart';
import 'package:easy_shop_client/features/payment/domain/payment_gateway.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Paymob "Intention" flow: create an intention, open its checkout page, then
// read the result from the redirect.
//
// It has its own Dio on purpose: the app's main Dio carries the course API key,
// which must never be sent to Paymob.
//
// The secret key lives in the app only because this is a course project; in
// production the server would create the intention and send the link.
class PaymobService implements PaymentGateway {
  PaymobService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;

  static const String _baseUrl = 'https://accept.paymob.com';
  static const String _checkoutUrl = 'https://eg.checkout.paymob.com/';
  static const String redirectionUrl = 'https://example.com/payment-result';

  static String get _secretKey => dotenv.get('PAYMOB_SECRET_KEY');
  static String get _publicKey => dotenv.get('PAYMOB_PUBLIC_KEY');
  static int get _cardIntegrationId =>
      dotenv.getInt('PAYMOB_CARD_INTEGRATION_ID');

  @override
  Future<Uri> createCheckout({
    required String orderCode,
    required double amount,
    required BillingData billing,
  }) async {
    final amountCents = (amount * 100).round();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/intention/',
        options: Options(headers: {'Authorization': 'Token $_secretKey'}),
        data: {
          'amount': amountCents,
          'currency': 'EGP',
          'payment_methods': [_cardIntegrationId],
          'items': [
            {
              'name': 'Order #$orderCode',
              'amount': amountCents,
              'description': 'Easy Shop order #$orderCode',
              'quantity': 1,
            },
          ],
          'billing_data': billing.toJson(),
          'special_reference': orderCode,
          'redirection_url': redirectionUrl,
        },
      );
      final clientSecret = response.data!['client_secret'] as String;
      return Uri.parse(
        '$_checkoutUrl?publicKey=$_publicKey&clientSecret=$clientSecret',
      );
    } on DioException catch (e) {
      throw PaymobException(
        e.response?.data?.toString() ?? e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  PaymentResult resultFromRedirect(String? redirectUrl) {
    if (redirectUrl == null || !redirectUrl.startsWith(redirectionUrl)) {
      return const PaymentResult(status: PaymentStatus.cancelled);
    }
    final params = Uri.parse(redirectUrl).queryParameters;
    final PaymentStatus status;
    if (params['pending'] == 'true') {
      status = PaymentStatus.pending;
    } else if (params['success'] == 'true') {
      status = PaymentStatus.success;
    } else {
      status = PaymentStatus.failed;
    }
    return PaymentResult(status: status, transactionId: params['id']);
  }
}
