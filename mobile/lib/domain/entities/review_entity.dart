import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int userId;
  final int chargerId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userImage;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.chargerId,
    required this.rating,
    this.comment,
    this.userName,
    this.userImage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        chargerId,
        rating,
        comment,
        userName,
        userImage,
        createdAt,
      ];
}
