import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/feature/order/domain/entities/order_entity.dart';
import 'package:localkart/feature/rating/domain/entities/rating_entity.dart';
import 'package:localkart/feature/rating/presentation/states/rating_state.dart';
import 'package:localkart/feature/rating/presentation/view_model/rating_view_model.dart';

/// Shows a rating dialog (centered) styled just like the reorder dialog.
/// Returns `true` if the rating was submitted/updated successfully.
Future<bool?> showRatingDialog(
  BuildContext context, {
  required OrderEntity order,
  RatingEntity? existingRating,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _RatingDialog(
      order: order,
      existingRating: existingRating,
    ),
  );
}

class _RatingDialog extends ConsumerStatefulWidget {
  final OrderEntity order;
  final RatingEntity? existingRating;

  const _RatingDialog({
    required this.order,
    this.existingRating,
  });

  @override
  ConsumerState<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<_RatingDialog> {
  int _selectedRating = 0;
  late TextEditingController _commentController;

  bool get _isEditing => widget.existingRating != null;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.existingRating?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existingRating?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ratingViewModelProvider);
    final isLoading = state.status == RatingStatus.loading;

    // Listen for success
    ref.listen(ratingViewModelProvider, (prev, next) {
      if (next.status == RatingStatus.success && next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    });

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Update Rating' : 'Rate Experience',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.order.shopName ?? widget.order.vendorName ?? 'Vendor'} • #${widget.order.orderNumber ?? ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    splashRadius: 20,
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Divider ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            const SizedBox(height: 16),

            // ── Content (scrollable) ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Delivery Date ──
                    if (widget.order.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Delivered on ${_formatDate(widget.order.createdAt!)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Overall Experience Label ──
                    const Text(
                      'Overall Experience',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Stars ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final isSelected = starNumber <= _selectedRating;
                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => setState(() => _selectedRating = starNumber),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.elasticOut,
                              transform: isSelected
                                  ? (Matrix4.identity()..scale(1.15))
                                  : Matrix4.identity(),
                              child: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 44,
                                color: isSelected
                                    ? AppColors.warning
                                    : AppColors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),

                    // ── Rating Label ──
                    Text(
                      _getRatingLabel(_selectedRating),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedRating > 0
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Comment ──
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        maxLength: 300,
                        enabled: !isLoading,
                        buildCounter: (context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 4),
                            child: Text(
                              '$currentLength/$maxLength',
                              style: TextStyle(
                                fontSize: 11,
                                color: currentLength > 280
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Share your experience (optional)',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Section ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: _isEditing ? 'Update Rating' : 'Submit Rating',
                        onPressed: _selectedRating > 0 ? _handleSubmit : () {},
                        height: 56,
                        borderRadius: 14,
                        isLoading: isLoading,
                        isEnabled: _selectedRating > 0 && !isLoading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final orderId = widget.order.orderId;
    if (orderId == null) return;

    final comment = _commentController.text.trim();

    if (_isEditing && widget.existingRating?.ratingId != null) {
      ref.read(ratingViewModelProvider.notifier).updateRating(
            ratingId: widget.existingRating!.ratingId!,
            rating: _selectedRating,
            comment: comment.isNotEmpty ? comment : '',
          );
    } else {
      ref.read(ratingViewModelProvider.notifier).createRating(
            orderId: orderId,
            rating: _selectedRating,
            comment: comment.isNotEmpty ? comment : '',
          );
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Tap a star to rate';
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
