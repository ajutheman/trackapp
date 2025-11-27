class Review {
  final String? id;
  final String bookingId;
  final String? tripId;
  final String? customerRequestId;
  final String connectRequestId;
  final String driverId;
  final String customerId;
  final String raterRole; // 'driver' or 'customer'
  final int rating; // 1-5
  final String? title;
  final String? comment;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Populated fields
  final Map<String, dynamic>? driver;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? booking;

  Review({
    this.id,
    required this.bookingId,
    this.tripId,
    this.customerRequestId,
    required this.connectRequestId,
    required this.driverId,
    required this.customerId,
    required this.raterRole,
    required this.rating,
    this.title,
    this.comment,
    this.isPublished = true,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.customer,
    this.booking,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'],
      bookingId: json['booking'] ?? json['bookingId'] ?? '',
      tripId: json['trip'] ?? json['tripId'],
      customerRequestId: json['customerRequest'] ?? json['customerRequestId'],
      connectRequestId: json['connectRequest'] ?? json['connectRequestId'] ?? '',
      driverId: json['driver'] is String 
          ? json['driver'] 
          : (json['driver']?['_id'] ?? json['driver']?['id'] ?? ''),
      customerId: json['customer'] is String
          ? json['customer']
          : (json['customer']?['_id'] ?? json['customer']?['id'] ?? ''),
      raterRole: json['raterRole'] ?? '',
      rating: json['rating'] ?? 0,
      title: json['title'],
      comment: json['comment'],
      isPublished: json['isPublished'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      driver: json['driver'] is Map ? json['driver'] : null,
      customer: json['customer'] is Map ? json['customer'] : null,
      booking: json['booking'] is Map ? json['booking'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'booking': bookingId,
      if (tripId != null) 'trip': tripId,
      if (customerRequestId != null) 'customerRequest': customerRequestId,
      'connectRequest': connectRequestId,
      'driver': driverId,
      'customer': customerId,
      'raterRole': raterRole,
      'rating': rating,
      if (title != null) 'title': title,
      if (comment != null) 'comment': comment,
      'isPublished': isPublished,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count
  final List<Review> recentReviews;

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(int.parse(key), value as int)) ??
          {},
      recentReviews: (json['recentReviews'] as List<dynamic>?)
              ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

