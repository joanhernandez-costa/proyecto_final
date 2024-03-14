class Review {
  final String review_id;
  final String? comment;
  final int? rating;
  final String? review_restaurant_id;
  final String? review_user_id;

  Review({
    required this.review_id,
    this.comment,
    this.rating,
    this.review_restaurant_id,
    this.review_user_id,
  });

  static Map<String, dynamic> toJson(Review reviews) {
    return {
      'review_id': reviews.review_id,
      'comment': reviews.comment,
      'rating': reviews.rating,
      'review_user_id': reviews.review_user_id,
      'review_restaurant_id': reviews.review_restaurant_id,
    };
  }

  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      review_id: json['id'] as String,
      comment: json['Comentario'] as String?,
      rating: json['Valoracion'] as int?,
      review_user_id: json['id_User'] as String?,
      review_restaurant_id: json['id_Restaurante'] as String?,
    );
  }
}