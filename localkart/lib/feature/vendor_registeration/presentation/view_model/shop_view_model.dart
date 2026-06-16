import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/vendor_registeration/domain/usecases/register_shop_usecase.dart';
import 'package:localkart/feature/vendor_registeration/presentation/states/shop_state.dart';

final shopViewModelProvider = NotifierProvider<ShopViewModel, ShopState>(
  () => ShopViewModel(),
);

class ShopViewModel extends Notifier<ShopState> {
  late final RegisterShopUsecase _registerShopUsecase;

  @override
  ShopState build() {
    _registerShopUsecase = ref.read(registerShopUsecaseProvider);
    return ShopState();
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
}
