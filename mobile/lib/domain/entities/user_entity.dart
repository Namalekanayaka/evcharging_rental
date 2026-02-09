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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      userType: json['userType'] as String? ?? json['user_type'] as String? ?? 'user',
      profileImage: json['profileImage'] as String? ?? json['profile_image'] as String?,
      bio: json['bio'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 
                     (json['average_rating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int? ?? json['total_reviews'] as int?,
      isVerified: json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'profileImage': profileImage,
      'bio': bio,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
