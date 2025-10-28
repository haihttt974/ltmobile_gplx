import 'package:flutter/material.dart';
import '../../Repository/auth_repository.dart';
import '../../Styles/app_colors.dart';
import '../Auth/forgot_password_newpass_view.dart';
// import AuthRepository sau khi bạn thêm verifyPasswordResetOtp

class ForgotPasswordOtpView extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpView({super.key, required this.email});

  @override
  State<ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<ForgotPasswordOtpView> {
  final _otpCtrl = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  String _errorMsg = "";
  String _successMsg = "";

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      setState(() {
        _errorMsg = "Vui lòng nhập mã OTP hợp lệ";
        _successMsg = "";
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = "";
      _successMsg = "";
    });

    try {
      // gọi API verify OTP -> backend trả resetToken
      final resetToken =
      await _repo.verifyForgotPassword(widget.email, otp);

      setState(() {
        _successMsg = "Mã OTP hợp lệ";
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordNewPassView(
            email: widget.email,
            resetToken: resetToken,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMsg = e
            .toString()
            .replaceAll(RegExp(r'Exception:|AuthException:'), '')
            .trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _gradientButton(String label) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9E2F), Color(0xFFFF6A00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: _loading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Quay lại",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.verified_user,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          "Nhập mã xác thực",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Mã OTP đã được gửi tới ${widget.email}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Mã OTP",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: Colors.white24, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: TextField(
                            controller: _otpCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "Nhập mã 6 số",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        if (_errorMsg.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorMsg,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _loading ? null : _verifyOtp,
                          child: _gradientButton("Xác nhận"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
