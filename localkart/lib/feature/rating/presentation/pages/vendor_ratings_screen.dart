import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/feature/auth/presentation/states/auth_state.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/presentation/states/rating_state.dart';
import 'package:localkart/feature/rating/presentation/view_model/rating_view_model.dart';

class VendorRatingsScreen extends ConsumerStatefulWidget {
  const VendorRatingsScreen({super.key});

  @override
  ConsumerState<VendorRatingsScreen> createState() =>
      _VendorRatingsScreenState();
}

class _VendorRatingsScreenState extends ConsumerState<VendorRatingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatings();
    });
  }

  void _loadRatings() {
    final authState = ref.read(authViewModelProvider);
    final userId = authState.authEntity?.userId;
    if (userId != null) {
      ref.read(ratingViewModelProvider.notifier).getVendorRatings(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ratingViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(state, authState),
    );
  }

  Widget _buildBody(RatingState state, AuthState authState) {
    final userId = authState.authEntity?.userId;

    if (state.status == RatingStatus.loading && state.ratings == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == RatingStatus.error && state.ratings == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load ratings',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadRatings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final ratings = state.ratings ?? [];
    final stats = state.vendorStats ?? const VendorRatingStats();

    return RefreshIndicator(
      onRefresh: () async {
        if (userId != null) {
          await ref
              .read(ratingViewModelProvider.notifier)
              .getVendorRatings(userId);
        }
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════════
          //  Overall Rating Card
          // ═══════════════════════════════════════════
          _buildOverallRatingCard(stats),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════
          //  Rating Distribution
          // ═══════════════════════════════════════════
          _buildRatingDistribution(stats),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════
          //  Customer Reviews Header
          // ═══════════════════════════════════════════
          Row(
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${ratings.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ═══════════════════════════════════════════
          //  Rating Cards List
          // ═══════════════════════════════════════════
          if (ratings.isEmpty)
            _buildEmptyState()
          else
            ...ratings.map((rating) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRatingCard(rating),
            )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOverallRatingCard(VendorRatingStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final filled = starNumber <= stats.averageRating.round();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 24,
                  color: filled ? AppColors.warning : Colors.white38,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.totalRatings} ${stats.totalRatings == 1 ? 'rating' : 'ratings'}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(VendorRatingStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final star = 5 - index; // 5, 4, 3, 2, 1
            final count = stats.distribution[star] ?? 0;
            final total = stats.totalRatings > 0
                ? stats.totalRatings
                : 1;
            final percentage = (count / total) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.inputFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStarColor(star),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingCard(RatingEntity rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info & Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryExtraLight,
                child: Text(
                  (rating.customerName ?? 'C')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name & Order
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.customerName ?? 'Customer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (rating.orderNumber != null)
                      Text(
                        'Order #${rating.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Date
              if (rating.createdAt != null)
                Text(
                  _formatDate(rating.createdAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Stars
          Row(
            children: List.generate(5, (index) {
              final filled = index < rating.rating;
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: filled ? AppColors.warning : AppColors.grey.withValues(alpha: 0.3),
                ),
              );
            }),
          ),

          // Comment
          if (rating.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              rating.comment,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No ratings yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Customer ratings will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStarColor(int star) {
    switch (star) {
      case 5:
        return const Color(0xFF22C55E);
      case 4:
        return const Color(0xFF66BB6A);
      case 3:
        return AppColors.warning;
      case 2:
        return Colors.orange;
      case 1:
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
