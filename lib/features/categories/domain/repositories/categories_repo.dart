import 'package:easy_shop_client/features/categories/domain/entities/category_entity.dart';

abstract class CategoriesRepo {
  Future<List<CategoryEntity>> getCategories();
}
