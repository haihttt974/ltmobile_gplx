import 'package:flutter/material.dart';
import '../../Repository/auth_repository.dart';
import '../../Styles/app_colors.dart';
import 'login_view.dart';
// import AuthRepository sau khi bạn thêm resetPassword

class ForgotPasswordNewPassView extends StatefulWidget {
  final String email;
  final String resetToken;

  const ForgotPasswordNewPassView({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ForgotPasswordNewPassView> createState() =>
      _ForgotPasswordNewPassViewState();
}

class _ForgotPasswordNewPassViewState extends State<ForgotPasswordNewPassView> {
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;
  String _errorMsg = "";
  String _successMsg = "";

  Future<void> _changePassword() async {
    final p1 = _pass1Ctrl.text;
    final p2 = _pass2Ctrl.text;
    final _repo = AuthRepository();

    if (p1.isEmpty || p1.length < 6) {
      setState(() {
        _errorMsg = "Mật khẩu quá ngắn (ít nhất 6 ký tự)";
        _successMsg = "";
      });
      return;
    }
    if (p1 != p2) {
      setState(() {
        _errorMsg = "Mật khẩu nhập lại không khớp";
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
      // await AuthRepository().resetPassword(
      //   email: widget.email,
      //   resetToken: widget.resetToken,
      //   newPassword: p1,
      // );
      await _repo.resetPassword(widget.resetToken, p1);
      setState(() {
        _successMsg = "Đổi mật khẩu thành công. Bạn có thể đăng nhập lại.";
      });

      // Có thể pop về LoginView ở đây
      // Navigator.pushReplacement(...)
      if (!mounted) return;
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     builder: (_) => LoginView(), // TODO: thay bằng LoginView()
      //   ),
      //       (route) => false,
      // );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    } catch (e) {
      setState(() {
        _errorMsg =
            e.toString().replaceAll(RegExp(r'Exception:|AuthException:'), '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
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
                        const Icon(Icons.lock_reset,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          "Đặt mật khẩu mới",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Nhập mật khẩu mới của bạn",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ô nhập mk mới
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Mật khẩu mới",
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
                            controller: _pass1Ctrl,
                            obscureText: true,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "Nhập mật khẩu mới",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ô nhập lại mk
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Nhập lại mật khẩu",
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
                            controller: _pass2Ctrl,
                            obscureText: true,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "Nhập lại mật khẩu mới",
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
                        if (_successMsg.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _successMsg,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _loading ? null : _changePassword,
                          child: _gradientButton("Đổi mật khẩu"),
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
