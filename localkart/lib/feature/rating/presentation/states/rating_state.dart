import 'package:equatable/equatable.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';

enum RatingStatus { initial, loading, loaded, error, success }

class VendorRatingStats extends Equatable {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution;

  const VendorRatingStats({
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.distribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  VendorRatingStats copyWith({
    double? averageRating,
    int? totalRatings,
    Map<int, int>? distribution,
  }) {
    return VendorRatingStats(
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      distribution: distribution ?? this.distribution,
    );
  }

  @override
  List<Object?> get props => [averageRating, totalRatings, distribution];
}

class RatingState extends Equatable {
  final RatingStatus status;
  final List<RatingEntity>? ratings;
  final RatingEntity? currentRating;
  final VendorRatingStats? vendorStats;
  final String? errorMessage;
  final String? successMessage;

  const RatingState({
    this.status = RatingStatus.initial,
    this.ratings,
    this.currentRating,
    this.vendorStats,
    this.errorMessage,
    this.successMessage,
  });

  RatingState copyWith({
    RatingStatus? status,
    List<RatingEntity>? ratings,
    RatingEntity? currentRating,
    VendorRatingStats? vendorStats,
    String? errorMessage,
    String? successMessage,
    bool clearRatings = false,
    bool clearCurrentRating = false,
    bool clearVendorStats = false,
  }) {
    return RatingState(
      status: status ?? this.status,
      ratings: clearRatings ? null : (ratings ?? this.ratings),
      currentRating: clearCurrentRating
          ? null
          : (currentRating ?? this.currentRating),
      vendorStats: clearVendorStats
          ? null
          : (vendorStats ?? this.vendorStats),
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    ratings,
    currentRating,
    vendorStats,
    errorMessage,
    successMessage,
  ];
}
