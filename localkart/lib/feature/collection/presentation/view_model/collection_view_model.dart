import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/collection/domain/usecases/add_product_to_collection_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/create_collection_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/delete_collection_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/get_all_collections_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/get_collection_by_id_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/remove_product_from_collection_usecase.dart';
import 'package:localkart/feature/collection/domain/usecases/update_collection_name_usecase.dart';
import 'package:localkart/feature/collection/presentation/states/collection_state.dart';

final collectionViewModelProvider =
    NotifierProvider<CollectionViewModel, CollectionState>(
        () => CollectionViewModel());

class CollectionViewModel extends Notifier<CollectionState> {
  late final GetAllCollectionsUsecase _getAllCollectionsUsecase;
  late final GetCollectionByIdUsecase _getCollectionByIdUsecase;
  late final CreateCollectionUsecase _createCollectionUsecase;
  late final DeleteCollectionUsecase _deleteCollectionUsecase;
  late final AddProductToCollectionUsecase _addProductToCollectionUsecase;
  late final RemoveProductFromCollectionUsecase
      _removeProductFromCollectionUsecase;
  late final UpdateCollectionNameUsecase _updateCollectionNameUsecase;

  @override
  CollectionState build() {
    _getAllCollectionsUsecase = ref.read(getAllCollectionsUsecaseProvider);
    _getCollectionByIdUsecase = ref.read(getCollectionByIdUsecaseProvider);
    _createCollectionUsecase = ref.read(createCollectionUsecaseProvider);
    _deleteCollectionUsecase = ref.read(deleteCollectionUsecaseProvider);
    _addProductToCollectionUsecase =
        ref.read(addProductToCollectionUsecaseProvider);
    _removeProductFromCollectionUsecase =
        ref.read(removeProductFromCollectionUsecaseProvider);
    _updateCollectionNameUsecase =
        ref.read(updateCollectionNameUsecaseProvider);

    return const CollectionState();
  }

  Future<void> getAllCollections() async {
    state = state.copyWith(status: CollectionStatus.loading);
    final result = await _getAllCollectionsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CollectionStatus.error,
          errorMessage: failure.message,
        );
      },
      (collections) {
        state = state.copyWith(
          status: CollectionStatus.loaded,
          collections: collections,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getCollectionById(String collectionId) async {
    state = state.copyWith(status: CollectionStatus.loading);
    final params = GetCollectionByIdParams(collectionId: collectionId);

    final result = await _getCollectionByIdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CollectionStatus.error,
          errorMessage: failure.message,
        );
      },
      (collection) {
        state = state.copyWith(
          status: CollectionStatus.loaded,
          selectedCollection: collection,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> createCollection(String collectionName) async {
    state = state.copyWith(isCreating: true, errorMessage: null);
    final params = CreateCollectionParams(collectionName: collectionName);

    final result = await _createCollectionUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: failure.message,
        );
      },
      (collection) {
        state = state.copyWith(
          isCreating: false,
          collections: [...state.collections, collection],
          errorMessage: null,
        );
      },
    );
  }

  Future<void> deleteCollection(String collectionId) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);
    final params = DeleteCollectionParams(collectionId: collectionId);

    final result = await _deleteCollectionUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isDeleting: false,
          collections:
              state.collections.where((c) => c.collectionId != collectionId).toList(),
          errorMessage: null,
        );
      },
    );
  }

  Future<void> addProductToCollection(
      String collectionId, String productId) async {
    state = state.copyWith(errorMessage: null);
    final params = AddProductToCollectionParams(
      collectionId: collectionId,
      productId: productId,
    );

    final result = await _addProductToCollectionUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedCollection) {
        state = state.copyWith(
          collections: state.collections.map((c) {
            if (c.collectionId == collectionId) return updatedCollection;
            return c;
          }).toList(),
          selectedCollection: updatedCollection,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> removeProductFromCollection(
      String collectionId, String productId) async {
    state = state.copyWith(errorMessage: null);
    final params = RemoveProductFromCollectionParams(
      collectionId: collectionId,
      productId: productId,
    );

    final result = await _removeProductFromCollectionUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedCollection) {
        state = state.copyWith(
          collections: state.collections.map((c) {
            if (c.collectionId == collectionId) return updatedCollection;
            return c;
          }).toList(),
          selectedCollection: updatedCollection,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateCollectionName(
      String collectionId, String newName) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    final params = UpdateCollectionNameParams(
      collectionId: collectionId,
      newName: newName,
    );

    final result = await _updateCollectionNameUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
      },
      (updatedCollection) {
        state = state.copyWith(
          isUpdating: false,
          collections: state.collections.map((c) {
            if (c.collectionId == collectionId) return updatedCollection;
            return c;
          }).toList(),
          selectedCollection: updatedCollection,
          errorMessage: null,
        );
      },
    );
  }
}
