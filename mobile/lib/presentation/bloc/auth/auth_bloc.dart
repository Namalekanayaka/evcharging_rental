import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Enhanced Authentication BLoC
/// Manages all authentication flows and session management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailOTPEvent>(_onVerifyEmailOTP);
    on<VerifyPhoneOTPEvent>(_onVerifyPhoneOTP);
    on<LoginEvent>(_onLogin);
    on<ResendOTPEvent>(_onResendOTP);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<LogoutEvent>(_onLogout);
    on<ChangePasswordEvent>(_onChangePassword);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ResetPasswordEvent>(_onResetPassword);
    on<Send2FAEvent>(_onSend2FA);
    on<Verify2FAEvent>(_onVerify2FA);
    on<GetSessionsEvent>(_onGetSessions);
    on<TerminateSessionEvent>(_onTerminateSession);
  }

  /// Check if user is already authenticated
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final authData = await _authRepository.getAuthData();
        emit(AuthAuthenticated(
          user: UserEntity(
            id: int.parse(authData['userId'] ?? '0'),
            email: authData['email'] ?? '',
            phone: authData['phone'] ?? '',
            firstName: authData['firstName'] ?? '',
            lastName: authData['lastName'] ?? '',
            userType: authData['userType'] ?? 'user',
            isVerified: authData['isVerified'] as bool? ?? false,
            createdAt: authData['createdAt'] != null 
              ? DateTime.parse(authData['createdAt'] as String) 
              : DateTime.now(),
          ),
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle registration
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.register(
        email: event.email,
        phone: event.phone,
        password: event.password,
        confirmPassword: event.confirmPassword,
        firstName: event.firstName,
        lastName: event.lastName,
        userType: event.userType,
      );

      emit(RegisterSuccess(
        userId: result['userId'],
        email: result['email'],
        phone: result['phone'],
        message: result['message'],
      ));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle email OTP verification
  Future<void> _onVerifyEmailOTP(
    VerifyEmailOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyEmailOTP(
        userId: event.userId,
        otp: event.otp,
      );

      emit(OTPVerified(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle phone OTP verification
  Future<void> _onVerifyPhoneOTP(
    VerifyPhoneOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.verifyPhoneOTP(
        userId: event.userId,
        otp: event.otp,
      );

      emit(OTPVerified(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      final user = UserEntity.fromJson(result['user']);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle OTP resend
  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.resendOTP(
        userId: event.userId,
        contact: event.contact,
        type: event.type,
      );

      emit(OTPResent(message: 'OTP resent successfully'));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle token refresh
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.refreshAccessToken();
      emit(const TokenRefreshed());
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout(allDevices: event.allDevices);
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Still logout locally even if API call fails
      await _authRepository.clearAuthData();
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle password change
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(const PasswordChanged());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle password reset request
  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.requestPasswordReset(email: event.email);
      emit(const PasswordResetRequested());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle password reset
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.resetPassword(
        userId: event.userId,
        otp: event.otp,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle 2FA sending
  Future<void> _onSend2FA(
    Send2FAEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.send2FA(method: event.method);
      emit(const TwoFASent());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle 2FA verification
  Future<void> _onVerify2FA(
    Verify2FAEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.verify2FA(
        code: event.code,
        method: event.method,
      );

      emit(const TwoFAVerified());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle getting sessions
  Future<void> _onGetSessions(
    GetSessionsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final sessions = await _authRepository.getUserSessions();
      emit(SessionsLoaded(sessions: sessions));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle session termination
  Future<void> _onTerminateSession(
    TerminateSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.terminateSession(sessionId: event.sessionId);
      emit(const SessionTerminated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
