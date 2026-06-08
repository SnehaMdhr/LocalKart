import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? phone;
  // final String role;
  final String? password;
  final String? confirmPassword;
  final String? username;
  final String? imageUrl;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    // required this.role,
    this.password,
    this.confirmPassword,
    this.username,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    phone,
    email,
    // role,
    password,
    confirmPassword,
    username,
    imageUrl,
  ];
}
