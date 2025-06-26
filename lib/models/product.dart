class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;
  final String idTenant;
  final bool is_active;
  

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.idTenant,
    required this.is_active
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  factory Product.fromMap(Map<String, dynamic> map) {
  return Product(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    price: (map['price'] as num).toDouble() ,
    idTenant: map['tenant_id'],
    is_active: map['is_active'],
    image: map['image'],
  );
}
}
