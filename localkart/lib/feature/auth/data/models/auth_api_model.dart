

import 'package:localkart/feature/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  // final String role;
  final String? username;
  final String? password;
  final String? confirmPassword;
  final String? imageUrl;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    // required this.role,
    this.username,
    this.password,
    this.confirmPassword,
    this.imageUrl,
  });

  //toJson
  Map<String, dynamic> toJson() {
    final payload = {
      "name": name,
      "email": email,
      "phone": phone,
      // "role": role,
      "username": username,
      "password": password,
      "confirmPassword": confirmPassword,
    };

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      payload["imageUrl"] = imageUrl;
    }

    return payload;
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json["id"] as String? ?? json["_id"] as String?,
      name: json["name"] as String? ?? "",
      email: json["email"] as String? ?? "",
      phone: json["phone"] as String?,
      // role: json["role"] as String? ?? "customer",
      username: json["username"] as String?,
      imageUrl:
          json["imageUrl"] as String? ?? json["profilePicture"] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      name: name,
      email: email,
      phone: phone,
      // role: role,
      username: username,
      imageUrl: imageUrl,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      name: entity.name,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      imageUrl: entity.imageUrl,
      phone: entity.phone,
      // role: entity.role,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
