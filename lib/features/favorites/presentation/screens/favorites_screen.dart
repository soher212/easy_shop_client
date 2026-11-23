import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/empty_state.dart';
import 'package:easy_shop_client/core/widgets/error_view.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_summary_tile.dart';
import 'package:easy_shop_client/core/widgets/screen_title_bar.dart';
import 'package:easy_shop_client/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  final ValueChanged<ProductEntity> onOpenProduct;

  const FavoritesScreen({super.key, required this.onOpenProduct});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTitleBar(title: 'Favorites'),
        Expanded(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              if (state.status == FavoritesStatus.loading &&
                  state.favorites.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == FavoritesStatus.failure &&
                  state.favorites.isEmpty) {
                return ErrorView(
                  message: state.message ?? 'Could not load your favorites',
                  onRetry: () => context.read<FavoritesCubit>().load(),
                );
              }
              if (state.favorites.isEmpty) {
                return const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorites yet',
                  message: 'Save products you love and find them here.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<FavoritesCubit>().load(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: state.favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = state.favorites[index];
                    return ProductSummaryTile(
                      product: product,
                      onTap: () => onOpenProduct(product),
                      footer: Text(
                        'by ${product.merchantName}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      trailing: GestureDetector(
                        onTap: () =>
                            context.read<FavoritesCubit>().toggle(product),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.favorite,
                            color: AppColors.error,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
