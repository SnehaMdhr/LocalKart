import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/feature/rating/domain/usecases/create_rating_usecase.dart';
import 'package:localkart/feature/rating/domain/usecases/get_vendor_ratings_usecase.dart';
import 'package:localkart/feature/rating/domain/usecases/get_order_rating_usecase.dart';
import 'package:localkart/feature/rating/domain/usecases/update_rating_usecase.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/presentation/states/rating_state.dart';

final ratingViewModelProvider =
    NotifierProvider<RatingViewModel, RatingState>(() => RatingViewModel());

class RatingViewModel extends Notifier<RatingState> {
  late final CreateRatingUsecase _createRatingUsecase;
  late final GetVendorRatingsUsecase _getVendorRatingsUsecase;
  late final GetOrderRatingUsecase _getOrderRatingUsecase;
  late final UpdateRatingUsecase _updateRatingUsecase;

  @override
  RatingState build() {
    _createRatingUsecase = ref.read(createRatingUsecaseProvider);
    _getVendorRatingsUsecase = ref.read(getVendorRatingsUsecaseProvider);
    _getOrderRatingUsecase = ref.read(getOrderRatingUsecaseProvider);
    _updateRatingUsecase = ref.read(updateRatingUsecaseProvider);

    return const RatingState();
  }

  /// Submit a new rating for a delivered order
  Future<RatingEntity?> createRating({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(status: RatingStatus.loading, errorMessage: null);

    final params = CreateRatingParams(
      orderId: orderId,
      rating: rating,
      comment: comment,
    );

    final result = await _createRatingUsecase(params);

    RatingEntity? createdRating;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: failure.message,
        );
      },
      (rating) {
        createdRating = rating;
        state = state.copyWith(
          status: RatingStatus.success,
          currentRating: rating,
          successMessage: "Rating submitted successfully!",
          errorMessage: null,
        );
      },
    );

    return createdRating;
  }

  /// Fetch vendor ratings and stats
  Future<void> getVendorRatings(String vendorId) async {
    state = state.copyWith(status: RatingStatus.loading, errorMessage: null);

    final params = GetVendorRatingsParams(vendorId: vendorId);
    final result = await _getVendorRatingsUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: failure.message,
        );
      },
      (ratings) {
        // Calculate stats from the ratings list
        if (ratings.isEmpty) {
          state = state.copyWith(
            status: RatingStatus.loaded,
            ratings: ratings,
            vendorStats: const VendorRatingStats(),
            errorMessage: null,
          );
          return;
        }

        final totalRatings = ratings.length;
        final sum = ratings.fold<int>(0, (acc, r) => acc + r.rating);
        final averageRating =
            totalRatings > 0
                ? double.parse((sum / totalRatings).toStringAsFixed(1))
                : 0.0;

        final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        for (final r in ratings) {
          distribution[r.rating] = (distribution[r.rating] ?? 0) + 1;
        }

        state = state.copyWith(
          status: RatingStatus.loaded,
          ratings: ratings,
          vendorStats: VendorRatingStats(
            averageRating: averageRating,
            totalRatings: totalRatings,
            distribution: distribution,
          ),
          errorMessage: null,
        );
      },
    );
  }

  /// Check if an order has already been rated
  Future<void> getOrderRating(String orderId) async {
    state = state.copyWith(status: RatingStatus.loading, errorMessage: null);

    final params = GetOrderRatingParams(orderId: orderId);
    final result = await _getOrderRatingUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: RatingStatus.loaded,
          currentRating: null,
          errorMessage: null, // Not showing error for not found
        );
      },
      (rating) {
        state = state.copyWith(
          status: RatingStatus.loaded,
          currentRating: rating,
          errorMessage: null,
        );
      },
    );
  }

  /// Update an existing rating
  Future<RatingEntity?> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  }) async {
    state = state.copyWith(status: RatingStatus.loading, errorMessage: null);

    final params = UpdateRatingParams(
      ratingId: ratingId,
      rating: rating,
      comment: comment,
    );

    final result = await _updateRatingUsecase(params);

    RatingEntity? updatedRating;
    result.fold(
      (failure) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: failure.message,
        );
      },
      (rating) {
        updatedRating = rating;
        state = state.copyWith(
          status: RatingStatus.success,
          currentRating: rating,
          successMessage: "Rating updated successfully!",
          errorMessage: null,
        );
      },
    );

    return updatedRating;
  }

  /// Clear the success state
  void clearSuccess() {
    state = state.copyWith(
      status: RatingStatus.loaded,
      successMessage: null,
    );
  }

  /// Reset the state
  void reset() {
    state = const RatingState();
  }
}
