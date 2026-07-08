import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/vendor_registeration/domain/usecases/get_my_shop_usecase.dart';
import 'package:localkart/feature/vendor_registeration/domain/usecases/register_shop_usecase.dart';
import 'package:localkart/feature/vendor_registeration/domain/usecases/update_shop_usecase.dart';
import 'package:localkart/feature/vendor_registeration/presentation/states/shop_state.dart';

final shopViewModelProvider = NotifierProvider<ShopViewModel, ShopState>(
  () => ShopViewModel(),
);

class ShopViewModel extends Notifier<ShopState> {
  late final RegisterShopUsecase _registerShopUsecase;
  late final GetMyShopUsecase _getMyShopUsecase;
  late final UpdateShopUsecase _updateShopUsecase;

  @override
  ShopState build() {
    _registerShopUsecase = ref.read(registerShopUsecaseProvider);
    _getMyShopUsecase = ref.read(getMyShopUsecaseProvider);
    _updateShopUsecase = ref.read(updateShopUsecaseProvider);
    return const ShopState();
  }

  Future<void> getMyShop() async {
    state = state.copyWith(status: ShopStatus.loading);
    final result = await _getMyShopUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ShopStatus.error,
          errorMessage: failure.message,
        );
      },
      (shop) {
        state = state.copyWith(
          status: ShopStatus.loaded,
          shopEntity: shop,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> registerShop({
    required String shopName,
    required String address,
    required String description,
    required List<String> categories,
  }) async {
    state = state.copyWith(status: ShopStatus.loading);

    final params = RegisterShopUsecaseParams(
      shopName: shopName,
      address: address,
      description: description,
      categories: categories,
    );

    final result = await _registerShopUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ShopStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: ShopStatus.registered);
        }
      },
    );
  }

  Future<void> updateShop({
    required String shopName,
    required String address,
    required String description,
    required List<String> categories,
  }) async {
    state = state.copyWith(status: ShopStatus.loading);

    final params = UpdateShopUsecaseParams(
      shopName: shopName,
      address: address,
      description: description,
      categories: categories,
    );

    final result = await _updateShopUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ShopStatus.error,
          errorMessage: failure.message,
        );
      },
      (shop) {
        state = state.copyWith(
          status: ShopStatus.loaded,
          shopEntity: shop,
          errorMessage: null,
        );
      },
    );
  }
}
