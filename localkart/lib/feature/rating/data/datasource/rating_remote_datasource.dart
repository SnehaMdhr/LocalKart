import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/feature/rating/data/models/rating_api_model.dart';

final ratingRemoteDatasourceProvider =
    Provider<IRatingRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RatingRemoteDatasource(apiClient: apiClient);
});

abstract interface class IRatingRemoteDatasource {
  Future<RatingApiModel?> createRating({
    required String orderId,
    required int rating,
    String? comment,
  });
  Future<List<RatingApiModel>> getVendorRatings(String vendorId);
  Future<RatingApiModel?> getOrderRating(String orderId);
  Future<RatingApiModel?> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  });
  Future<void> deleteRating(String ratingId);
}

class RatingRemoteDatasource implements IRatingRemoteDatasource {
  final ApiClient _apiClient;

  RatingRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<RatingApiModel?> createRating({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.createRating,
      data: {
        'orderId': orderId,
        'rating': rating,
        'comment': comment ?? '',
      },
    );
    final data = response.data['data'];
    if (data == null) return null;
    return RatingApiModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<RatingApiModel>> getVendorRatings(String vendorId) async {
    final response = await _apiClient.get(
      ApiEndpoints.vendorRatings(vendorId),
    );
    final ratingsData = response.data['ratings'] as List<dynamic>? ?? [];
    return ratingsData
        .map((e) => RatingApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RatingApiModel?> getOrderRating(String orderId) async {
    final response = await _apiClient.get(
      ApiEndpoints.orderRating(orderId),
    );
    final data = response.data['data'];
    if (data == null) return null;
    return RatingApiModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<RatingApiModel?> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    final response = await _apiClient.patch(
      ApiEndpoints.updateRating(ratingId),
      data: body,
    );
    final data = response.data['data'];
    if (data == null) return null;
    return RatingApiModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteRating(String ratingId) async {
    await _apiClient.delete(
      ApiEndpoints.deleteRating(ratingId),
    );
  }
}
