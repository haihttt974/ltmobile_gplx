import 'package:flutter/material.dart';
import '../../Components/app_text_field.dart';
import '../../Components/primary_button.dart';
import '../../Components/error_text.dart';
import '../../Repository/auth_repository.dart';
import '../../Styles/app_colors.dart';
import '../../Styles/text_styles.dart';
import '../Home/main_home_view.dart';
import '../../Utils/validators.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  bool _rememberMe = false;
  String _errorMsg = "";

  Future<void> _handleLogin() async {
    final emailError = Validators.validateEmail(_emailCtrl.text.trim());
    final passError = Validators.validatePassword(_passCtrl.text);

    if (emailError != null) {
      setState(() => _errorMsg = emailError);
      return;
    }
    if (passError != null) {
      setState(() => _errorMsg = passError);
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = "";
    });

    try {
      await _repo.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainHomeView()),
      );
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: Implement Google login
    print("Google login pressed");
  }

  Future<void> _handleFacebookLogin() async {
    // TODO: Implement Facebook login
    print("Facebook login pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Ôn tập GPLX",
                    style: AppTextStyles.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Học lái xe dễ dàng, thi đỗ nhanh chóng",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 16),

                  // Email label
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _emailCtrl,
                    hintText: "example@gmail.com",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Password label
                  const Text(
                    "Mật khẩu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _passCtrl,
                    hintText: "••••••••",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 12),

                  // Remember me & Forgot password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.blue;
                                  }
                                  return Colors.white24;
                                },
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Ghi nhớ trong 30 ngày tới",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: điều hướng quên mật khẩu
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ErrorText(message: _errorMsg),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    label: "Đăng nhập",
                    loading: _loading,
                    onPressed: _loading ? null : _handleLogin,
                  ),

                  const SizedBox(height: 20),

                  // Divider with "Hoặc"
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white24,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Hoặc",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Social login buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Google",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleFacebookLogin,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Facebook",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Chưa có tài khoản? ",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: điều hướng đăng ký
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Đăng ký ngay",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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