import 'package:easy_shop_client/features/categories/domain/entities/category_entity.dart';
import 'package:easy_shop_client/features/categories/domain/repositories/categories_repo.dart';

class GetCategoriesUseCase {
  final CategoriesRepo _categoriesRepo;

  GetCategoriesUseCase(this._categoriesRepo);

  Future<List<CategoryEntity>> call() => _categoriesRepo.getCategories();
}
