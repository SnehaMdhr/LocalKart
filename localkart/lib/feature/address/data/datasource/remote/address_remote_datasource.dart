import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/address/data/datasource/address_datasource.dart';
import 'package:localkart/feature/address/data/models/address_api_model.dart';

final addressRemoteDatasourceProvider = Provider<IAddressRemoteDatasource>((ref) {
  return AddressRemoteDatasource(apiclient: ref.read(apiClientProvider));
});

class AddressRemoteDatasource implements IAddressRemoteDatasource {
  final ApiClient _apiClient;

  AddressRemoteDatasource({required ApiClient apiclient})
      : _apiClient = apiclient;

  @override
  Future<AddressApiModel?> createAddress({
    required String label,
    required String fullAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createAddress,
        data: {
          'label': label,
          'fullAddress': fullAddress,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return AddressApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AddressApiModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getAddresses);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return [];

      // Handle wrapped response { success: true, data: [...] }
      final data = responseData['data'] as List<dynamic>?;
      if (data != null) {
        return data
            .map((e) => AddressApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Handle direct array response
      return responseData.entries
          .map((e) => AddressApiModel.fromJson(e.value as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddressApiModel?> getAddressById(String addressId) async {
    try {
      final path = '${ApiEndpoints.getAddressById}$addressId';
      final response = await _apiClient.get(path);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return AddressApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddressApiModel?> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final path = '${ApiEndpoints.updateAddress}$addressId';
      final data = <String, dynamic>{};
      if (label != null) data['label'] = label;
      if (fullAddress != null) data['fullAddress'] = fullAddress;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await _apiClient.put(path, data: data);

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) return null;

      return AddressApiModel.fromJsonWithData(responseData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final path = '${ApiEndpoints.deleteAddress}$addressId';
      await _apiClient.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
