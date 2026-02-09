import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String userType;
  final String? profileImage;
  final String? bio;
  final double? averageRating;
  final int? totalReviews;
  final bool isVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.profileImage,
    this.bio,
    this.averageRating,
    this.totalReviews,
    required this.isVerified,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        firstName,
        lastName,
        userType,
        profileImage,
        bio,
        averageRating,
        totalReviews,
        isVerified,
        createdAt,
      ];
}
