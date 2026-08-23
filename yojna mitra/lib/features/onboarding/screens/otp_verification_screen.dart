import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yojana_mitra/core/constants/app_colors.dart';

/// OTP verification screen shown after "Get OTP" is tapped on the login
/// screen. The code is sent and verified through Firebase Phone
/// Authentication — `verificationId` is the token Firebase returned when
/// it sent the SMS, and is combined with the digits the user types to
/// build a credential that signs them in.
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _kDarkGreen = AppColors.primaryGreen;
  static const _kOrange = AppColors.primaryOrange;

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _verificationId;
  String? _error;
  bool _verifying = false;
  bool _resending = false;

  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() {
      _resending = true;
      _error = null;
      for (final c in _controllers) {
        c.clear();
      }
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phoneNumber}',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/profile-setup',
            arguments: widget.phoneNumber,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _resending = false;
            _error = e.message ?? 'OTP भेजने में समस्या / Failed to resend OTP';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resending = false;
          });
          _startTimer();
          _focusNodes.first.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'नया OTP भेजा गया / New OTP sent',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _kDarkGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _resending = false);
    }
  }

  Future<void> _verifyOtp() async {
    final entered = _controllers.map((c) => c.text).join();

    if (entered.length < 6) {
      setState(() => _error = 'कृपया पूरा OTP दर्ज करें / Please enter the full OTP');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: entered,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/profile-setup',
        arguments: widget.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.code == 'invalid-verification-code'
            ? 'गलत OTP, कृपया पुनः प्रयास करें / Incorrect OTP, please try again'
            : (e.message ?? 'सत्यापन विफल / Verification failed');
      });
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit once all six boxes are filled.
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      FocusScope.of(context).unfocus();
      _verifyOtp();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kDarkGreen),
              ),
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _kDarkGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.sms_outlined, color: _kDarkGreen, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'OTP सत्यापन / OTP Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+91 ${widget.phoneNumber} पर भेजा गया 6-अंकों का कोड डालें\nEnter the 6-digit code sent to +91 ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _otpBox(i)),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.error_outline, size: 14, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : const Text(
                          'सत्यापित करें / Verify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'OTP दोबारा भेजें ${_secondsLeft}s में / Resend in ${_secondsLeft}s',
                        style: const TextStyle(color: Colors.black45, fontSize: 13),
                      )
                    : GestureDetector(
                        onTap: _resending ? null : _resendOtp,
                        child: _resending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: _kDarkGreen,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'OTP दोबारा भेजें / Resend OTP',
                                style: TextStyle(
                                  color: _kDarkGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 46,
      height: 54,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _kDarkGreen,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kOrange, width: 1.8),
          ),
        ),
        onChanged: (v) => _onDigitChanged(index, v),
      ),
    );
  }
}