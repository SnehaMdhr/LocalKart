import 'package:equatable/equatable.dart';
import '../../domain/entities/collection_entity.dart';

enum CollectionStatus { initial, loading, loaded, error }

class CollectionState extends Equatable {
  final CollectionStatus status;
  final List<CollectionEntity> collections;
  final CollectionEntity? selectedCollection;
  final String? errorMessage;
  final bool isCreating;
  final bool isDeleting;

  const CollectionState({
    this.status = CollectionStatus.initial,
    this.collections = const [],
    this.selectedCollection,
    this.errorMessage,
    this.isCreating = false,
    this.isDeleting = false,
  });

  CollectionState copyWith({
    CollectionStatus? status,
    List<CollectionEntity>? collections,
    CollectionEntity? selectedCollection,
    String? errorMessage,
    bool? isCreating,
    bool? isDeleting,
  }) {
    return CollectionState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      selectedCollection: selectedCollection ?? this.selectedCollection,
      errorMessage: errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
    status,
    collections,
    selectedCollection,
    errorMessage,
    isCreating,
    isDeleting,
  ];
}
