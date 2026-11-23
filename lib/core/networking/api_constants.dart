import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => dotenv.get('API_BASE_URL');
  static String get apiKey => dotenv.get('API_KEY');

  static const String login = 'client/login';
  static const String register = 'client/register';
  static const String verifyOtp = 'client/otp/verify';
  static const String resendOtp = 'client/otp/resend';
  static const String logout = 'client/logout';

  static const String profile = 'client/profile';
  static const String updateProfile = 'client/profile/update';

  static const String categories = 'client/categories';
  static const String products = 'client/products';
  static String productDetails(String slug) => 'client/products/show/$slug';

  static const String favorites = 'client/favorites';
  static const String addFavorite = 'client/favorites/store';
  static const String removeFavorite = 'client/favorites/destroy';

  static const String cart = 'client/carts';
  static const String addToCart = 'client/carts/store';
  static const String removeFromCart = 'client/carts/destroy';

  static const String orders = 'client/orders';
  static const String placeOrder = 'client/orders/store';
  static String orderDetails(String code) => 'client/orders/show/$code';
  static String payOrder(String code) => 'client/orders/pay/$code';
  static const String processPayment = 'client/payments/process';
}
