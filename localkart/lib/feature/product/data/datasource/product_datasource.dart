import 'package:localkart/feature/product/data/models/product_api_model.dart';
import 'package:localkart/feature/product/data/models/product_hive_model.dart';

abstract interface class IProductLocalDatasource {
  Future<List<ProductHiveModel>?> getAllProducts();
  Future<ProductHiveModel?> getProductById(String productId);
  Future<void> cacheProducts(List<ProductHiveModel> products);
}

abstract interface class IProductRemoteDatasource {
  Future<List<ProductApiModel>?> getAllProducts();
  Future<ProductApiModel?> getProductById(String productId);
}
