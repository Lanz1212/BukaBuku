import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/review_service.dart';
import '../models/book_review.dart';
import '../widgets/star_rating_input.dart';

class WriteReviewScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final String orderId;
  final BookReview? initialReview;

  const WriteReviewScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.orderId,
    this.initialReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late int _rating;
  late TextEditingController _commentController;
  BookReview? _existingReview;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _existingReview = widget.initialReview;
    _rating = widget.initialReview?.rating ?? 5;
    _commentController = TextEditingController(text: widget.initialReview?.comment ?? '');
    _checkExistingReview();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingReview() async {
    if (_existingReview == null) {
      final review = await ReviewService.fetchUserReviewForBook(widget.bookId);
      if (review != null && mounted) {
        setState(() {
          _existingReview = review;
          _rating = review.rating;
          _commentController.text = review.comment;
        });
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih rating bintang terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ReviewService.submitOrUpdateReview(
        bookId: widget.bookId,
        orderId: widget.orderId.replaceAll('#', '').trim(),
        rating: _rating,
        comment: comment,
        existingReviewId: _existingReview?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _existingReview != null
                        ? 'Ulasan berhasil diperbarui!'
                        : 'Terima kasih! Ulasan buku berhasil dikirim.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteReview() async {
    if (_existingReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ulasan?'),
        content: const Text(
          'Ulasan dan rating Anda untuk buku ini akan dihapus dari sistem.',
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

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await ReviewService.deleteReview(_existingReview!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan telah dihapus.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus ulasan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _existingReview != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Ulasan Buku' : 'Tulis Ulasan Buku',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Book Summary Header Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 56,
                              height: 76,
                              color: AppColors.surfaceContainerHigh,
                              child: widget.bookCoverUrl.isNotEmpty
                                  ? Image.network(
                                      widget.bookCoverUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                        Icons.menu_book_rounded,
                                        size: 28,
                                        color: AppColors.secondary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.menu_book_rounded,
                                      size: 28,
                                      color: AppColors.secondary,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Pesanan #${widget.orderId.replaceAll('#', '')}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.onSecondaryContainer,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.bookTitle,
                                  style: AppTypography.titleMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.bookAuthor,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Rating Star Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Bagaimana penilaian Anda?',
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sentuh bintang untuk memberikan nilai',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          StarRatingInput(
                            rating: _rating,
                            starSize: 42,
                            onRatingChanged: (newRating) {
                              setState(() => _rating = newRating);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Review Comment Input
                    Text(
                      'Tulis Ulasan Anda (Opsional)',
                      style: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.8),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 5,
                        maxLength: 1000,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Ceritakan apa yang membuat buku ini menarik, gaya penulisan, atau bab favorit Anda...',
                          hintStyle: AppTypography.bodyMd.copyWith(
                            color: AppColors.outline,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. Genuine Review Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ulasan Anda akan tampil secara publik dengan lencana "Terverifikasi" karena Anda telah membeli buku ini di Toko Buku Budi.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 5. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEditMode ? 'Simpan Perubahan' : 'Kirim Ulasan'),
                      ),
                    ),

                    if (isEditMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _deleteReview,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text('Hapus Ulasan Ini'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: AppTypography.labelLg.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

