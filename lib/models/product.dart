class Product {
  final String id;
  final String name;
  final String image;
  final int price;
  final String description;
  final String idSeller;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,

    required this.idSeller,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
