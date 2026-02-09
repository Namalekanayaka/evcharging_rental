import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends Equatable {
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

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] ?? json['first_name'] as String,
      lastName: json['lastName'] ?? json['last_name'] as String,
      userType: json['userType'] ?? json['user_type'] as String,
      profileImage: json['profileImage'] ?? json['profile_image'] as String?,
      bio: json['bio'] as String?,
      averageRating:
          (json['averageRating'] ?? json['average_rating'])?.toDouble(),
      totalReviews: json['totalReviews'] ?? json['total_reviews'] as int?,
      isVerified: json['isVerified'] ?? json['is_verified'] as bool? ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? json['created_at'] as String),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      userType: userType,
      profileImage: profileImage,
      bio: bio,
      averageRating: averageRating,
      totalReviews: totalReviews,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }

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
