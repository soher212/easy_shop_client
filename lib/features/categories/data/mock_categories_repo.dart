import 'package:easy_shop_client/features/categories/domain/entities/category_entity.dart';
import 'package:easy_shop_client/features/categories/domain/repositories/categories_repo.dart';

// Temporary: the real categories come from the merchants through the server.
class MockCategoriesRepo implements CategoriesRepo {
  @override
  Future<List<CategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      CategoryEntity(id: 1, name: 'Mobile Phone'),
      CategoryEntity(id: 2, name: 'Mobile Covers'),
      CategoryEntity(id: 3, name: 'Laptops'),
      CategoryEntity(id: 4, name: 'Audio'),
      CategoryEntity(id: 5, name: 'Accessories'),
    ];
  }
}
