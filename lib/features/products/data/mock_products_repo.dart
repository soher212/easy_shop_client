import 'package:easy_shop_client/features/products/domain/entities/product_entity.dart';
import 'package:easy_shop_client/features/products/domain/repositories/products_repo.dart';

// Temporary sample data taken from the design. The real products come from
// the merchants through the server, so this is replaced when it is back.
class MockProductsRepo implements ProductsRepo {
  @override
  Future<List<ProductEntity>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _products;
  }

  static const _products = [
    ProductEntity(
      id: 1,
      slug: 'samsung-a-24',
      name: 'Samsung A24',
      categoryId: 1,
      categoryName: 'Mobile Phone',
      price: 150,
      stock: 12,
      merchantName: 'Elbatal Store',
      description:
          '6.5" Super AMOLED display, 50MP triple camera, 5000mAh battery, '
          '4GB RAM.',
    ),
    ProductEntity(
      id: 2,
      slug: 'iphone-14',
      name: 'iPhone 14',
      categoryId: 1,
      categoryName: 'Mobile Phone',
      price: 550,
      stock: 8,
      merchantName: 'Apple Hub Egypt',
      description: '6.1" Super Retina display, dual camera, A15 Bionic chip.',
    ),
    ProductEntity(
      id: 3,
      slug: 'redmi-note-12',
      name: 'Redmi Note 12',
      categoryId: 1,
      categoryName: 'Mobile Phone',
      price: 120,
      stock: 25,
      merchantName: 'Xiaomi Egypt',
      description: '6.67" AMOLED display, 50MP camera, fast charging.',
    ),
    ProductEntity(
      id: 4,
      slug: 'samsung-a24-case',
      name: 'Samsung A24 Case',
      categoryId: 2,
      categoryName: 'Mobile Covers',
      price: 15,
      stock: 60,
      merchantName: 'Elbatal Store',
      description: 'Shockproof protective case.',
    ),
    ProductEntity(
      id: 5,
      slug: 'iphone-14-case',
      name: 'iPhone 14 Case',
      categoryId: 2,
      categoryName: 'Mobile Covers',
      price: 25,
      stock: 40,
      merchantName: 'Case World',
      description: 'Slim case with a soft inner lining.',
    ),
    ProductEntity(
      id: 6,
      slug: 'macbook-air-m2',
      name: 'MacBook Air M2',
      categoryId: 3,
      categoryName: 'Laptops',
      price: 1200,
      stock: 5,
      merchantName: 'Apple Hub Egypt',
      description: '13.6" Liquid Retina display, M2 chip, 18-hour battery.',
    ),
    ProductEntity(
      id: 7,
      slug: 'dell-xps-15',
      name: 'Dell XPS 15',
      categoryId: 3,
      categoryName: 'Laptops',
      price: 980,
      stock: 0,
      merchantName: 'Dell',
      description: '15.6" OLED display, Intel Core i7, 16GB RAM.',
    ),
    ProductEntity(
      id: 8,
      slug: 'airpods-pro',
      name: 'AirPods Pro',
      categoryId: 4,
      categoryName: 'Audio',
      price: 200,
      stock: 30,
      merchantName: 'Apple Hub Egypt',
      description: 'Active noise cancellation and spatial audio.',
    ),
    ProductEntity(
      id: 9,
      slug: 'usb-c-hub-7-in-1',
      name: 'USB-C Hub 7-in-1',
      categoryId: 5,
      categoryName: 'Accessories',
      price: 35,
      stock: 50,
      merchantName: 'TechGear Egypt',
      description: 'HDMI, USB 3.0, SD card reader and more.',
    ),
    ProductEntity(
      id: 10,
      slug: 'wireless-charger',
      name: 'Wireless Charger',
      categoryId: 5,
      categoryName: 'Accessories',
      price: 28,
      stock: 35,
      merchantName: 'TechGear Egypt',
      description: '15W fast wireless charging pad.',
    ),
  ];
}
