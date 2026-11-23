class ProductEntity {
  final int id;
  final String slug;
  final String name;
  final int categoryId;
  final String categoryName;
  final double price;
  final int stock;
  final String merchantName;
  final String description;
  final String imagePath;

  const ProductEntity({
    required this.id,
    required this.slug,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.stock,
    required this.merchantName,
    this.description = '',
    this.imagePath = '',
  });

  bool get isOutOfStock => stock <= 0;
}
