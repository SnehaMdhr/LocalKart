import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/feature/order/data/datasource/order_datasource.dart';
import 'package:localkart/feature/order/data/models/order_hive_model.dart';

final orderLocalDatasourceProvider = Provider<IOrderLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return OrderLocalDatasource(hiveService: hiveService);
});

class OrderLocalDatasource implements IOrderLocalDatasource {
  final HiveService _hiveService;

  OrderLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<OrderHiveModel>> getOrders() async {
    try {
      return await _hiveService.getAllOrders();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheOrders(List<OrderHiveModel> orders) async {
    try {
      await _hiveService.cacheOrders(orders);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearOrders() async {
    try {
      await _hiveService.clearOrdersLocally();
    } catch (e) {
      rethrow;
    }
  }
}
