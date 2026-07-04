import 'package:localkart/feature/address/data/models/address_api_model.dart';
import 'package:localkart/feature/address/data/models/address_hive_model.dart';

abstract interface class IAddressLocalDatasource {
  Future<List<AddressHiveModel>> getAddresses();
  Future<void> cacheAddresses(List<AddressHiveModel> addresses);
  Future<void> clearAddresses();
}

abstract interface class IAddressRemoteDatasource {
  Future<AddressApiModel?> createAddress({
    required String label,
    required String fullAddress,
    required double latitude,
    required double longitude,
  });
  Future<List<AddressApiModel>> getAddresses();
  Future<AddressApiModel?> getAddressById(String addressId);
  Future<AddressApiModel?> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
  });
  Future<void> deleteAddress(String addressId);
}
