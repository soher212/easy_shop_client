import 'package:dio/dio.dart';
import 'package:easy_shop_client/core/networking/api_service.dart';
import 'package:easy_shop_client/features/auth/data/auth_repo_impl.dart';
import 'package:easy_shop_client/features/auth/domain/repositories/auth_repo.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:easy_shop_client/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/cart/data/mock_cart_repo.dart';
import 'package:easy_shop_client/features/cart/domain/repositories/cart_repo.dart';
import 'package:easy_shop_client/features/cart/domain/usecases/cart_usecases.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/categories/data/mock_categories_repo.dart';
import 'package:easy_shop_client/features/categories/domain/repositories/categories_repo.dart';
import 'package:easy_shop_client/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:easy_shop_client/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop_client/features/payment/data/paymob_service.dart';
import 'package:easy_shop_client/features/payment/domain/payment_gateway.dart';
import 'package:easy_shop_client/features/orders/data/mock_orders_repo.dart';
import 'package:easy_shop_client/features/orders/domain/repositories/orders_repo.dart';
import 'package:easy_shop_client/features/orders/domain/usecases/orders_usecases.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/favorites/data/mock_favorites_repo.dart';
import 'package:easy_shop_client/features/favorites/domain/repositories/favorites_repo.dart';
import 'package:easy_shop_client/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop_client/features/products/data/mock_products_repo.dart';
import 'package:easy_shop_client/features/products/domain/repositories/products_repo.dart';
import 'package:easy_shop_client/features/products/domain/usecases/get_products_usecase.dart';
import 'package:easy_shop_client/features/profile/data/mock_profile_repo.dart';
import 'package:easy_shop_client/features/profile/domain/repositories/profile_repo.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:easy_shop_client/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_form_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt()));

  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(getIt()));
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt()),
  );
  getIt.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(getIt()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt()));
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  // Mock repositories until the server is back: swap these four lines for
  // the real implementations and nothing else changes.
  getIt.registerLazySingleton<ProductsRepo>(() => MockProductsRepo());
  getIt.registerLazySingleton<CategoriesRepo>(() => MockCategoriesRepo());
  getIt.registerLazySingleton<FavoritesRepo>(() => MockFavoritesRepo());
  getIt.registerLazySingleton<ProfileRepo>(() => MockProfileRepo());

  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(getIt()),
  );
  getIt.registerLazySingleton<AddFavoriteUseCase>(
    () => AddFavoriteUseCase(getIt()),
  );
  getIt.registerLazySingleton<RemoveFavoriteUseCase>(
    () => RemoveFavoriteUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt()),
  );

  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt(), getIt()));
  getIt.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt()),
  );
  getIt.registerFactory<ProfileFormCubit>(() => ProfileFormCubit(getIt()));

  getIt.registerLazySingleton<CartRepo>(() => MockCartRepo());
  getIt.registerLazySingleton<GetCartUseCase>(() => GetCartUseCase(getIt()));
  getIt.registerLazySingleton<AddToCartUseCase>(
    () => AddToCartUseCase(getIt()),
  );
  getIt.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(getIt()),
  );
  getIt.registerFactory<CartCubit>(() => CartCubit(getIt(), getIt(), getIt()));

  getIt.registerLazySingleton<OrdersRepo>(() => MockOrdersRepo(getIt()));
  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt()),
  );
  getIt.registerLazySingleton<PlaceOrderUseCase>(
    () => PlaceOrderUseCase(getIt()),
  );
  getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt()));
  getIt.registerLazySingleton<PaymentGateway>(() => PaymobService());
  getIt.registerFactory<CheckoutCubit>(() => CheckoutCubit(getIt(), getIt()));
}
