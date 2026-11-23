part of 'home_cubit.dart';

sealed class HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final int? selectedCategoryId;
  final String query;

  HomeSuccess({
    required this.products,
    required this.categories,
    this.selectedCategoryId,
    this.query = '',
  });

  List<ProductEntity> get visibleProducts {
    final text = query.trim().toLowerCase();
    return products.where((product) {
      final inCategory =
          selectedCategoryId == null ||
          product.categoryId == selectedCategoryId;
      final matches =
          text.isEmpty ||
          product.name.toLowerCase().contains(text) ||
          product.categoryName.toLowerCase().contains(text) ||
          product.merchantName.toLowerCase().contains(text);
      return inCategory && matches;
    }).toList();
  }

  HomeSuccess copyWith({int? selectedCategoryId, String? query}) {
    return HomeSuccess(
      products: products,
      categories: categories,
      selectedCategoryId: selectedCategoryId,
      query: query ?? this.query,
    );
  }
}

class HomeFailure extends HomeState {
  final String message;

  HomeFailure(this.message);
}
