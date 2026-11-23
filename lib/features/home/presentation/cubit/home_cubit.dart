import 'package:easy_shop_client/core/networking/api_error_handler.dart';
import 'package:easy_shop_client/features/categories/domain/entities/category_entity.dart';
import 'package:easy_shop_client/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetProductsUseCase _getProducts;
  final GetCategoriesUseCase _getCategories;

  HomeCubit(this._getProducts, this._getCategories) : super(HomeLoading());

  Future<void> load() async {
    emit(HomeLoading());
    try {
      final (products, categories) = await (
        _getProducts(),
        _getCategories(),
      ).wait;
      emit(HomeSuccess(products: products, categories: categories));
    } catch (error) {
      emit(HomeFailure(ApiErrorHandler.getMessage(error)));
    }
  }

  // null means "All".
  void selectCategory(int? categoryId) {
    final current = state;
    if (current is HomeSuccess) {
      emit(current.copyWith(selectedCategoryId: categoryId));
    }
  }

  void search(String query) {
    final current = state;
    if (current is HomeSuccess) {
      emit(
        HomeSuccess(
          products: current.products,
          categories: current.categories,
          selectedCategoryId: current.selectedCategoryId,
          query: query,
        ),
      );
    }
  }
}
