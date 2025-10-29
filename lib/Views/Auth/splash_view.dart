import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/main_home_view.dart';
import 'login_view.dart';
import '../../../Styles/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    // logic tối giản: chỉ cần có token là coi như đăng nhập
    final Widget next = (token != null && token.isNotEmpty)
        ? const MainHomeView()
        : const LoginView();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
