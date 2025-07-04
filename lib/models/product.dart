class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;
  final String idTenant;
  final String address;
  final bool is_active;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.idTenant,
    required this.address,
    required this.is_active,
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
      price: double.tryParse(map['price'].toString()) ?? 0,
      idTenant: map['tenant_id'],
      address: map['address'],
      is_active: map['is_active'],
      image: map['image'],
    );
  }
}
