import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/domain/repositories/products_repo.dart';

class GetProductsUseCase {
  final ProductsRepo _productsRepo;

  GetProductsUseCase(this._productsRepo);

  Future<List<ProductEntity>> call() => _productsRepo.getProducts();
}
