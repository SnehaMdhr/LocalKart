import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/product/data/datasource/product_datasource.dart';
import 'package:localkart/feature/product/data/models/product_api_model.dart';

final productRemoteDatasourceProvider = Provider<IProductRemoteDatasource>((
  ref,
) {
  return ProductRemoteDatasource(apiclient: ref.read(apiClientProvider));
});

class ProductRemoteDatasource implements IProductRemoteDatasource {
  final ApiClient _apiClient;

  ProductRemoteDatasource({required ApiClient apiclient})
    : _apiClient = apiclient;
  @override
  Future<List<ProductApiModel>?> getAllProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getAllProduct);

      final responseMap = response.data as Map<String, dynamic>?;
      if (responseMap == null) return null;

      final dataList = responseMap['data'] as List?;
      if (dataList == null) return null;

      return ProductApiModel.fromJsonList(dataList);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductApiModel?> getProductById(String productId) async {
    try {
      final path = ApiEndpoints.getProductById.replaceAll(':id', productId);
      final response = await _apiClient.get(path);

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      return ProductApiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
