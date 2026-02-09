import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

/// OTP Verification Page
/// Verifies OTP sent to email or phone
class OTPVerificationPage extends StatefulWidget {
  final int userId;
  final String contactMethod; // 'email' or 'phone'
  final String maskedContact; // Masked email/phone for display

  const OTPVerificationPage({
    Key? key,
    required this.userId,
    required this.contactMethod,
    required this.maskedContact,
  }) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  late List<TextEditingController> _otpControllers;
  late FocusNode _focusNode;
  int _remainingSeconds = 300; // 5 minutes
  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNode = FocusNode();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  /// Start countdown timer
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        _startTimer();
      } else if (mounted && _remainingSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP expired. Please resend.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  /// Get OTP string from controllers
  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  /// Check if all OTP fields are filled
  bool _isOTPComplete() {
    return _otpControllers.every((c) => c.text.isNotEmpty);
  }

  /// Format remaining time
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Handle OTP verification
  void _verifyOTP() {
    final otp = _getOTP();

    if (widget.contactMethod == 'email') {
      context.read<AuthBloc>().add(
            VerifyEmailOTPEvent(userId: widget.userId, otp: otp),
          );
    } else {
      context.read<AuthBloc>().add(
            VerifyPhoneOTPEvent(userId: widget.userId, otp: otp),
          );
    }
  }

  /// Handle resend OTP
  void _resendOTP() {
    context.read<AuthBloc>().add(
          ResendOTPEvent(
            userId: widget.userId,
            contact: widget.maskedContact,
            type: widget.contactMethod,
          ),
        );

    setState(() => _remainingSeconds = 300);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OTPVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP verified successfully!')),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final isExpired = _remainingSeconds == 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a code to\n${widget.maskedContact}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OTP Input Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => _buildOTPField(
                          index: index,
                          controller: _otpControllers[index],
                          enabled: !isLoading && !isExpired,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timer and Resend
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isExpired ? Colors.red[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isExpired
                                  ? Colors.red[200]!
                                  : Colors.orange[200]!,
                            ),
                          ),
                          child: Text(
                            isExpired
                                ? 'OTP Expired'
                                : 'Expires in ${_formatTime(_remainingSeconds)}',
                            style: TextStyle(
                              color:
                                  isExpired ? Colors.red : Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isExpired)
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _resendOTP,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Resend Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          )
                        else
                          RichText(
                            text: TextSpan(
                              text: "Didn't receive the code? ",
                              style: TextStyle(color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: 'Resend',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = isLoading ? null : _resendOTP,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Verify Button
                  ElevatedButton(
                    onPressed: (!_isOTPComplete() || isLoading || isExpired)
                        ? null
                        : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Security Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Never share this code with anyone. We will never ask for it.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build individual OTP input field
  Widget _buildOTPField({
    required int index,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counter: const SizedBox.shrink(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < 5) {
              FocusScope.of(context).nextFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          }
        },
        onSubmitted: (_) {
          if (_isOTPComplete()) {
            _verifyOTP();
          }
        },
      ),
    );
  }
}
