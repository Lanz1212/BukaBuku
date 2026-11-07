class BookReview {
  final int id;
  final String bookId;
  final String userId;
  final String orderId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookReview({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.orderId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  String get reviewerInitials {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months bulan lalu';
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  factory BookReview.fromMap(Map<String, dynamic> map) {
    return BookReview(
      id: (map['id'] as num?)?.toInt() ?? 0,
      bookId: map['book_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      orderId: map['order_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? 'Pembaca',
      userAvatar: map['user_avatar'] as String?,
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      comment: map['comment'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'user_id': userId,
      'order_id': orderId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
    };
  }
}

