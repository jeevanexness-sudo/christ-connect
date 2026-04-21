import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/auth_provider.dart' as ap;
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneCtrl  = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  String _countryCode = '+91';
  bool   _sending   = false;
  String? _localError;

  static const _countryCodes = ['+91', '+1', '+44', '+61', '+971', '+234', '+254', '+27'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _sending = true; _localError = null; });

    final auth  = context.read<ap.AuthProvider>();
    final phone = '$_countryCode${_phoneCtrl.text.trim()}';
    final error = await auth.sendOtp(phone);

    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      setState(() => _localError = error);
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpScreen(phone: phone)));
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
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.phone_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),

              Text('Phone Verification', style: AppTextStyles.authTitle),
              const SizedBox(height: 8),
              Text("Enter your mobile number.\nWe'll send a 6-digit OTP to verify.", style: AppTextStyles.authSubtitle),
              const SizedBox(height: 36),

              // Form
              Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MOBILE NUMBER', style: AppTextStyles.inputLabel),
                  const SizedBox(height: 8),
                  // Phone input row
                  Row(children: [
                    // Country code picker
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          Text(_countryCode, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down_rounded, color: AppColors.muted, size: 18),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Number field
                    Expanded(
                      child: TextFormField(
                        controller:  _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        style: GoogleFonts.nunito(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(hintText: '9876543210', hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 14)),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter phone number';
                          if (v.trim().length < 7) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                    ),
                  ]),

                  // Error
                  if (_localError != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBox(message: _localError!),
                  ],

                  const SizedBox(height: 32),

                  // Send OTP button
                  GestureDetector(
                    onTap: _sending ? null : _sendOtp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: _sending
                          ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                          : Text('Send OTP', textAlign: TextAlign.center, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                    ),
                  ),
                ]),
              ),

              const Spacer(),

              // Info note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.muted, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Standard SMS rates may apply. OTP expires in 60 seconds.', style: AppTextStyles.caption.copyWith(height: 1.5))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Select Country Code', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ..._countryCodes.map((code) => ListTile(
            title: Text(code, style: AppTextStyles.bodyBold),
            trailing: _countryCode == code ? const Icon(Icons.check_rounded, color: AppColors.gold) : null,
            onTap: () { setState(() => _countryCode = code); Navigator.pop(context); },
          )),
        ]),
      ),
    );
  }
}

// ─── Error Box ────────────────────────────────────────────────────────────
class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

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
