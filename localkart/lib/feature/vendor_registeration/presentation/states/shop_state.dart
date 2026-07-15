import 'package:equatable/equatable.dart';
import '../../domain/entities/shop_entity.dart';

enum ShopStatus {
  initial,
  loading,
  loaded,
  registered,
  error,
}

class ShopState extends Equatable {
  final ShopStatus status;
  final ShopEntity? shopEntity;
  final String? errorMessage;

  const ShopState({
    this.status = ShopStatus.initial,
    this.shopEntity,
    this.errorMessage,
  });

  ShopState copyWith({
    ShopStatus? status,
    ShopEntity? shopEntity,
    String? errorMessage,
  }) {
    return ShopState(
      status: status ?? this.status,
      shopEntity: shopEntity ?? this.shopEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shopEntity, errorMessage];
}
