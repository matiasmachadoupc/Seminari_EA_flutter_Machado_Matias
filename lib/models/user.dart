class User {
  final String? id;
  final String name;
  final int age;
  final String email;
  final String password;
  final String? phone; // Nuevo campo
  final String? address; // Nuevo campo

  User({
    this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.password,
    this.phone,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Asegúrate de usar 'id' en lugar de '_id'
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'], // Nuevo campo
      address: json['address'], // Nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'age': age,
      'email': email,
      'password': password,
      'phone': phone, // Nuevo campo
      'address': address, // Nuevo campo
    };
  }
}
