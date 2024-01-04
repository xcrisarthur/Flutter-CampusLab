// user_model.dart
class User {
  final String email;
  final String id;
  final String name;
  final String role;

  User({
    required this.email,
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      id: map['id'],
      name: map['name'],
      role: map['role'],
    );
  }
}