import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/error_view.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop_client/features/home/presentation/widgets/category_chips.dart';
import 'package:easy_shop_client/features/home/presentation/widgets/home_header.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<ProductEntity>? onOpenProduct;

  const HomeScreen({super.key, this.onOpenProduct});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => switch (state) {
        HomeLoading() => const Center(child: CircularProgressIndicator()),
        HomeFailure(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<HomeCubit>().load(),
        ),
        HomeSuccess() => RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().load(),
          child: _Content(state: state, onOpenProduct: onOpenProduct),
        ),
      },
    );
  }
}

class _Content extends StatelessWidget {
  final HomeSuccess state;
  final ValueChanged<ProductEntity>? onOpenProduct;

  const _Content({required this.state, this.onOpenProduct});

  @override
  Widget build(BuildContext context) {
    final products = state.visibleProducts;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.spaceLarge,
              AppDimensions.screenPadding,
              AppDimensions.spaceSmall + 4,
            ),
            child: const Text('Categories', style: AppTextStyles.subtitle),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryChips(
            categories: state.categories,
            selectedId: state.selectedCategoryId,
            onSelected: context.read<HomeCubit>().selectCategory,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.spaceLarge,
              AppDimensions.screenPadding,
              AppDimensions.spaceSmall + 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Products', style: AppTextStyles.subtitle),
                Text('${products.length} items', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No products found', style: AppTextStyles.caption),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              0,
              AppDimensions.screenPadding,
              AppDimensions.spaceLarge,
            ),
            sliver: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favorites) => SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 222,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    isFavorite: favorites.isFavorite(product.id),
                    onToggleFavorite: () =>
                        context.read<FavoritesCubit>().toggle(product),
                    onTap: onOpenProduct == null
                        ? null
                        : () => onOpenProduct!(product),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
