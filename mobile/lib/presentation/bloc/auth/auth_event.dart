import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// User registration
class RegisterEvent extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String userType;

  const RegisterEvent({
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.userType,
  });

  @override
  List<Object> get props => [
        email,
        phone,
        password,
        confirmPassword,
        firstName,
        lastName,
        userType,
      ];
}

/// Verify email OTP
class VerifyEmailOTPEvent extends AuthEvent {
  final int userId;
  final String otp;

  const VerifyEmailOTPEvent({
    required this.userId,
    required this.otp,
  });

  @override
  List<Object> get props => [userId, otp];
}

/// Verify phone OTP
class VerifyPhoneOTPEvent extends AuthEvent {
  final int userId;
  final String otp;

  const VerifyPhoneOTPEvent({
    required this.userId,
    required this.otp,
  });

  @override
  List<Object> get props => [userId, otp];
}

/// User login
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Resend OTP
class ResendOTPEvent extends AuthEvent {
  final int userId;
  final String contact;
  final String type;

  const ResendOTPEvent({
    required this.userId,
    required this.contact,
    this.type = 'email',
  });

  @override
  List<Object> get props => [userId, contact, type];
}

/// Refresh access token
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

/// User logout
class LogoutEvent extends AuthEvent {
  final bool allDevices;

  const LogoutEvent({this.allDevices = false});

  @override
  List<Object> get props => [allDevices];
}

/// Change password
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}

/// Request password reset
class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Reset password with OTP
class ResetPasswordEvent extends AuthEvent {
  final int userId;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordEvent({
    required this.userId,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [userId, otp, newPassword, confirmPassword];
}

/// Send 2FA code
class Send2FAEvent extends AuthEvent {
  final String method;

  const Send2FAEvent({this.method = 'email'});

  @override
  List<Object> get props => [method];
}

/// Verify 2FA code
class Verify2FAEvent extends AuthEvent {
  final String code;
  final String method;

  const Verify2FAEvent({
    required this.code,
    this.method = 'email',
  });

  @override
  List<Object> get props => [code, method];
}

/// Get user sessions
class GetSessionsEvent extends AuthEvent {
  const GetSessionsEvent();
}

/// Terminate session
class TerminateSessionEvent extends AuthEvent {
  final String sessionId;

  const TerminateSessionEvent({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
