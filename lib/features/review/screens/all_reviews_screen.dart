import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/review_service.dart';
import '../models/book_review.dart';
import '../widgets/review_card.dart';

class AllReviewsScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final double currentRating;
  final int totalReviews;

  const AllReviewsScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.currentRating = 0.0,
    this.totalReviews = 0,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  List<BookReview> _reviews = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ReviewService.fetchBookReviews(widget.bookId),
      ReviewService.getEffectiveUserId(),
    ]);

    if (mounted) {
      setState(() {
        _reviews = results[0] as List<BookReview>;
        _currentUserId = results[1] as String?;
        _isLoading = false;
      });
    }
  }

  double get _avgRating {
    if (_reviews.isEmpty) return widget.currentRating;
    final sum = _reviews.fold<int>(0, (prev, r) => prev + r.rating);
    return sum / _reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final avg = _avgRating;
    final count = _reviews.isNotEmpty ? _reviews.length : widget.totalReviews;
    final dist = _ratingDistribution;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Ulasan Pembaca',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title Header
                    Text(
                      widget.bookTitle,
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating Summary Bento Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left: Big number + stars
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  count > 0 ? avg.toStringAsFixed(1) : '0.0',
                                  style: AppTypography.headlineLg.copyWith(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (i) {
                                    final isFilled = i < avg.round();
                                    return Icon(
                                      isFilled
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 16,
                                      color: isFilled
                                          ? const Color(0xFFE59819)
                                          : AppColors.outlineVariant,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count Ulasan Real',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 80,
                            width: 1,
                            color: AppColors.surfaceContainer,
                          ),

                          const SizedBox(width: 14),

                          // Right: 5 to 1 star progress bars
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [5, 4, 3, 2, 1].map((star) {
                                final c = dist[star] ?? 0;
                                final ratio = count > 0 ? c / count : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$star',
                                        style: AppTypography.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: Color(0xFFE59819),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: ratio,
                                            minHeight: 5,
                                            backgroundColor:
                                                AppColors.surfaceContainerHigh,
                                            valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                              Color(0xFFE59819),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      SizedBox(
                                        width: 18,
                                        child: Text(
                                          '$c',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.outline,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Daftar Ulasan (${_reviews.length})',
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_reviews.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.rate_review_outlined,
                              size: 40,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum Ada Ulasan',
                              style: AppTypography.titleMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Belum ada ulasan untuk buku ini. Beli buku dan bagikan pengalaman membaca Anda di sini!',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._reviews.map(
                        (review) => ReviewCard(
                          review: review,
                          isOwner: _currentUserId != null &&
                              review.userId == _currentUserId,
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Ulasan?'),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus ulasan ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ReviewService.deleteReview(review.id);
                              _loadReviews();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

