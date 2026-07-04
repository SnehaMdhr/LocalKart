import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/services/hive/hive.service.dart';
import 'package:localkart/feature/address/data/datasource/address_datasource.dart';
import 'package:localkart/feature/address/data/models/address_hive_model.dart';

final addressLocalDatasourceProvider = Provider<IAddressLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AddressLocalDatasource(hiveService: hiveService);
});

class AddressLocalDatasource implements IAddressLocalDatasource {
  final HiveService _hiveService;

  AddressLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<AddressHiveModel>> getAddresses() async {
    try {
      return await _hiveService.getAddresses();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheAddresses(List<AddressHiveModel> addresses) async {
    try {
      await _hiveService.cacheAddresses(addresses);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAddresses() async {
    try {
      await _hiveService.clearAddressesLocally();
    } catch (e) {
      rethrow;
    }
  }
}
