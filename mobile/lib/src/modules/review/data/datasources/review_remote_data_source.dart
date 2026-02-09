import 'package:dio/dio.dart';

abstract class ReviewRemoteDataSource {
  Future<Map<String, dynamic>> submitReview(
    int chargerId,
    double rating,
    String title,
    String reviewText, {
    double? cleanliness,
    double? safety,
    double? supportRating,
  });
  Future<Map<String, dynamic>> getChargerReviews(
      int chargerId, int limit, int offset);
  Future<Map<String, dynamic>> getUserReviews(int limit, int offset);
  Future<Map<String, dynamic>> getUserTrustScore();
  Future<Map<String, dynamic>> markReviewHelpful(int reviewId);
  Future<Map<String, dynamic>> markReviewUnhelpful(int reviewId);
  Future<Map<String, dynamic>> getPendingReviews(int limit, int offset);
  Future<Map<String, dynamic>> moderateReview(
      int reviewId, bool approved, String? reason);
  Future<Map<String, dynamic>> deleteReview(int reviewId);
  Future<Map<String, dynamic>> getReviewStatistics(int chargerId);
  Future<Map<String, dynamic>> getOwnerRating();
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '/api/reviews';

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> submitReview(
    int chargerId,
    double rating,
    String title,
    String reviewText, {
    double? cleanliness,
    double? safety,
    double? supportRating,
  }) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: {
          'chargerId': chargerId,
          'rating': rating,
          'title': title,
          'reviewText': reviewText,
          if (cleanliness != null) 'cleanliness': cleanliness,
          if (safety != null) 'safety': safety,
          if (supportRating != null) 'supportRating': supportRating,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getChargerReviews(
      int chargerId, int limit, int offset) async {
    try {
      final response = await dio.get(
        '$baseUrl/charger/$chargerId',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserReviews(int limit, int offset) async {
    try {
      final response = await dio.get(
        '$baseUrl/my-reviews',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserTrustScore() async {
    try {
      final response = await dio.get('$baseUrl/trust-score');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> markReviewHelpful(int reviewId) async {
    try {
      final response = await dio.post('$baseUrl/$reviewId/helpful');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> markReviewUnhelpful(int reviewId) async {
    try {
      final response = await dio.post('$baseUrl/$reviewId/unhelpful');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPendingReviews(int limit, int offset) async {
    try {
      final response = await dio.get(
        '$baseUrl/pending',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> moderateReview(
      int reviewId, bool approved, String? reason) async {
    try {
      final response = await dio.post(
        '$baseUrl/$reviewId/moderate',
        data: {
          'approved': approved,
          if (reason != null) 'reason': reason,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try {
      final response = await dio.delete('$baseUrl/$reviewId');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getReviewStatistics(int chargerId) async {
    try {
      final response = await dio.get('$baseUrl/stats/charger/$chargerId');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getOwnerRating() async {
    try {
      final response = await dio.get('$baseUrl/owner-rating');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Resource not found';
    }
    if (e.response?.statusCode == 400) {
      return e.response?.data['message'] ?? 'Bad request';
    }
    return e.message ?? 'Unknown error occurred';
  }
}
