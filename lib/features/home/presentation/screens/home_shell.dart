import 'package:easy_shop_client/core/routes/routes.dart';
import 'package:easy_shop_client/core/widgets/app_bottom_nav.dart';
import 'package:easy_shop_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/cart/presentation/screens/cart_screen.dart';
import 'package:easy_shop_client/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop_client/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:easy_shop_client/features/home/presentation/screens/home_screen.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/orders/presentation/screens/orders_screen.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/presentation/screens/product_details_screen.dart';
import 'package:easy_shop_client/features/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/cubit/profile_form_cubit.dart';
import 'package:easy_shop_client/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:easy_shop_client/features/profile/presentation/screens/profile_screen.dart';
import 'package:easy_shop_client/core/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _homeIndex = 0;
  static const _favoritesIndex = 1;
  static const _ordersIndex = 3;

  int _index = _homeIndex;

  void _select(int index) => setState(() => _index = index);

  void _editProfile(ProfileEntity profile) {
    final profileCubit = context.read<ProfileCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileCubit),
            BlocProvider(create: (_) => getIt<ProfileFormCubit>()),
          ],
          child: EditProfileScreen(profile: profile),
        ),
      ),
    );
  }

  // Pages pushed on top of the tabs get the same cubits the tabs use.
  void _openProduct(ProductEntity product) {
    final favorites = context.read<FavoritesCubit>();
    final cart = context.read<CartCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: favorites),
            BlocProvider.value(value: cart),
          ],
          child: ProductDetailsScreen(product: product),
        ),
      ),
    );
  }

  void _openCheckout() {
    final cart = context.read<CartCubit>();
    final orders = context.read<OrdersCubit>();
    final profile = switch (context.read<ProfileCubit>().state) {
      ProfileSuccess(:final profile) => profile,
      _ => null,
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<CheckoutCubit>()),
            BlocProvider.value(value: cart),
            BlocProvider.value(value: orders),
          ],
          child: CheckoutScreen(
            items: cart.state.items,
            initialAddress: profile?.address ?? '',
            initialLatitude: profile?.latitude,
            initialLongitude: profile?.longitude,
            billingName: profile?.name ?? '',
            billingEmail: profile?.email ?? '',
            billingPhone: profile?.phone ?? '',
            onViewOrders: () => _select(_ordersIndex),
            onContinueShopping: () => _select(_homeIndex),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartCubit, int>(
      (cubit) => cubit.state.itemsCount,
    );
    final items = [
      const BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
      ),
      const BottomNavItem(
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: 'Faves',
      ),
      BottomNavItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Cart',
        badgeCount: cartCount,
      ),
      const BottomNavItem(icon: Icons.inventory_2_outlined, label: 'Orders'),
      const BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    ];

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (_) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onOpenProduct: _openProduct),
            FavoritesScreen(onOpenProduct: _openProduct),
            CartScreen(onCheckout: _openCheckout, onOpenProduct: _openProduct),
            const OrdersScreen(),
            ProfileScreen(
              onEditProfile: _editProfile,
              onOpenOrders: () => _select(_ordersIndex),
              onOpenFavorites: () => _select(_favoritesIndex),
              onLogout: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          items: items,
          currentIndex: _index,
          onTap: _select,
        ),
      ),
    );
  }
}
