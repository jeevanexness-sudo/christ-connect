import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/auth_provider.dart' as ap;

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode>             _nodes = List.generate(6, (_) => FocusNode());

  int  _secondsLeft = 60;
  bool _canResend   = false;
  Timer? _timer;
  bool _verifying   = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _secondsLeft = 60; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() { _secondsLeft = 0; _canResend = true; });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otpValue => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpValue.length < 6) {
      setState(() => _error = 'Enter the complete 6-digit OTP.');
      return;
    }
    setState(() { _verifying = true; _error = null; });

    final auth = context.read<ap.AuthProvider>();
    final ok   = await auth.verifyOtp(_otpValue, widget.phone);

    if (!mounted) return;
    setState(() => _verifying = false);

    if (!ok) {
      setState(() => _error = auth.error ?? 'Verification failed.');
      // Clear OTP fields
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
    }
    // If ok → AuthWrapper handles redirect automatically
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    setState(() => _error = null);
    final auth  = context.read<ap.AuthProvider>();
    final error = await auth.sendOtp(widget.phone);
    if (error != null) {
      setState(() => _error = error);
    } else {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border2)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 18),
                ),
              ),
              const SizedBox(height: 32),

              // Icon
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(gradient: AppColors.violetGradient, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),

              Text('Enter OTP', style: AppTextStyles.authTitle),
              const SizedBox(height: 8),
              RichText(text: TextSpan(
                style: AppTextStyles.authSubtitle,
                children: [
                  const TextSpan(text: 'We sent a 6-digit code to '),
                  TextSpan(text: widget.phone, style: AppTextStyles.authSubtitle.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
                ],
              )),
              const SizedBox(height: 40),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode:  _nodes[i],
                  hasError:   _error != null,
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    }
                    if (val.isEmpty && i > 0) {
                      _nodes[i - 1].requestFocus();
                    }
                    // Auto verify when 6 digits entered
                    if (_otpValue.length == 6) _verify();
                  },
                )),
              ),
              const SizedBox(height: 16),

              // Error
              if (_error != null) _ErrorRow(message: _error!),

              const SizedBox(height: 28),

              // Verify button
              GestureDetector(
                onTap: _verifying ? null : _verify,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: _verifying
                      ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                      : Text('Verify OTP', textAlign: TextAlign.center, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                ),
              ),

              const SizedBox(height: 24),

              // Resend
              Center(
                child: GestureDetector(
                  onTap: _canResend ? _resend : null,
                  child: RichText(text: TextSpan(
                    style: AppTextStyles.body2,
                    children: [
                      const TextSpan(text: "Didn't receive the code? "),
                      TextSpan(
                        text: _canResend ? 'Resend OTP' : 'Resend in ${_secondsLeft}s',
                        style: AppTextStyles.linkText.copyWith(
                          color: _canResend ? AppColors.gold : AppColors.muted,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Single OTP Box ───────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final void Function(String) onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      child: TextField(
        controller:  controller,
        focusNode:   focusNode,
        keyboardType: TextInputType.number,
        textAlign:   TextAlign.center,
        maxLength:   1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white),
        decoration: InputDecoration(
          counterText: '',
          fillColor: hasError ? AppColors.danger.withOpacity(0.1) : AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? AppColors.danger : AppColors.border, width: hasError ? 1.5 : 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? AppColors.danger : AppColors.border, width: hasError ? 1.5 : 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? AppColors.danger : AppColors.gold, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: AppTextStyles.body2.copyWith(color: AppColors.danger))),
      ]),
    );
  }
}
