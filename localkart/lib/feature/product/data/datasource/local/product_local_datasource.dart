import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/feature/product/data/datasource/product_datasource.dart';
import 'package:localkart/feature/product/data/models/product_hive_model.dart';

final productLocalDatasourceProvider = Provider<ProductLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProductLocalDataSource(hiveService: hiveService);
});

class ProductLocalDataSource implements IProductLocalDatasource {
  final HiveService _hiveService;

  ProductLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<List<ProductHiveModel>?> getAllProducts() async {
    try {
      final products = await _hiveService.getAllProducts();
      if (products.isEmpty) return null;
      return products;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProductHiveModel?> getProductById(String productId) async {
    try {
      return await _hiveService.getProductById(productId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheProducts(List<ProductHiveModel> products) async {
    try {
      await _hiveService.cacheProducts(products);
    } catch (e) {
      rethrow;
    }
  }
}
