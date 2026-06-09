import 'package:hive/hive.dart';
import 'package:localkart/core/constants/hive_table_constants.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/auth_entity.dart';
part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  // @HiveField(3)
  // final String role;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? username;

  @HiveField(6)
  final String? imageUrl;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    this.phone,
    // required this.role,
    this.password,
    this.username,
    this.imageUrl,
  }) : userId = userId ?? const Uuid().v4();

  /// Entity → Hive
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      // role: entity.role,
      password: entity.password,
      username: entity.username,
      imageUrl: entity.imageUrl,
    );
  }

  /// Hive → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      // role: role,
      password: password,
      username: username,
      imageUrl: imageUrl,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
