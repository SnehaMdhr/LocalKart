import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/vendor_registeration/data/datasources/shop_datasource.dart';
import 'package:localkart/feature/vendor_registeration/data/models/shop_api_model.dart';

final shopRemoteDatasourceProvider = Provider<IShopRemoteDatasource>((ref) {
  return ShopRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class ShopRemoteDatasource implements IShopRemoteDatasource {
  final ApiClient _apiClient;

  ShopRemoteDatasource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<ShopApiModel?> registerShop(ShopApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.registerShop,
      data: model.toJson(),
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final registeredShop = ShopApiModel.fromJson(data);
      return registeredShop;
    }
    return model;
  }
}
