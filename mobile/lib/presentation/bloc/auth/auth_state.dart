import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth failure
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Registration successful, awaiting OTP verification
class RegisterSuccess extends AuthState {
  final int userId;
  final String email;
  final String phone;
  final String message;

  const RegisterSuccess({
    required this.userId,
    required this.email,
    required this.phone,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, email, phone, message];
}

/// OTP verified successfully
class OTPVerified extends AuthState {
  final UserEntity user;

  const OTPVerified({required this.user});

  @override
  List<Object?> get props => [user];
}

/// OTP resent
class OTPResent extends AuthState {
  final String message;

  const OTPResent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Token refreshed
class TokenRefreshed extends AuthState {
  const TokenRefreshed();
}

/// Password changed successfully
class PasswordChanged extends AuthState {
  const PasswordChanged();
}

/// Password reset requested
class PasswordResetRequested extends AuthState {
  const PasswordResetRequested();
}

/// Password reset successful
class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

/// 2FA code sent
class TwoFASent extends AuthState {
  const TwoFASent();
}

/// 2FA verified
class TwoFAVerified extends AuthState {
  const TwoFAVerified();
}

/// Sessions loaded
class SessionsLoaded extends AuthState {
  final List<Map<String, dynamic>> sessions;

  const SessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

/// Session terminated
class SessionTerminated extends AuthState {
  const SessionTerminated();
}
