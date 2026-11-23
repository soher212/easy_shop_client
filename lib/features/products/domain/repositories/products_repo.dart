import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';

abstract class ProductsRepo {
  Future<List<ProductEntity>> getProducts();
}
