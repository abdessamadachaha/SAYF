class Person {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  String? image; 


  Person({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.image,
  });

  factory Person.fromMap(Map<String, dynamic> map) {
  return Person(
    id: map['id'],
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? 'customer',
    image: map['image'],
  );
}

  
}