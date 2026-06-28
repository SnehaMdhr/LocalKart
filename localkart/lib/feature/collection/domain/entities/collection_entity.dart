import 'package:equatable/equatable.dart';

class CollectionEntity extends Equatable {
  final String? collectionId;
  final String userId;
  final String collectionName;
  final List<String> productIds;

  const CollectionEntity({
    this.collectionId,
    this.userId = '',
    required this.collectionName,
    this.productIds = const [],
  });

  CollectionEntity copyWith({
    String? collectionId,
    String? userId,
    String? collectionName,
    List<String>? productIds,
  }) {
    return CollectionEntity(
      collectionId: collectionId ?? this.collectionId,
      userId: userId ?? this.userId,
      collectionName: collectionName ?? this.collectionName,
      productIds: productIds ?? this.productIds,
    );
  }

  @override
  List<Object?> get props => [collectionId, userId, collectionName, productIds];
}
