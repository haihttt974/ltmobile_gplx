// main.dart

import 'dart:io';

import 'package:flutter/material.dart';

// Auth screens
import 'Utils/http_overrides.dart';
import 'Views/Auth/splash_view.dart';
import 'Views/Auth/login_view.dart';
import 'Views/Auth/register_view.dart';
import 'Views/Auth/verify_otp_view.dart';
import 'Views/Auth/forgot_password_view.dart';
import 'Views/Auth/forgot_password_otp_view.dart';
import 'Views/Auth/forgot_password_newpass_view.dart';

// Home screen
import 'Views/Home/main_home_view.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const GPLXApp());
}

class GPLXApp extends StatelessWidget {
  const GPLXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ôn tập GPLX",
      debugShowCheckedModeBanner: false,
      // Màn hình đầu tiên khi mở app
      initialRoute: '/splash',

      // Định nghĩa tất cả các route
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const MainHomeView(),
        '/forgot-password': (context) => const ForgotPasswordView(),

        // Các route cần nhận dữ liệu qua arguments
        '/verify-otp': (context) {
          // Lấy email từ arguments được truyền qua
          final email = ModalRoute.of(context)?.settings.arguments as String;
          return VerifyOtpView(email: email);
        },

        '/forgot-password-otp': (context) {
          // Lấy email từ arguments
          final email = ModalRoute.of(context)?.settings.arguments as String;
          return ForgotPasswordOtpView(email: email);
        },

        '/forgot-password-newpass': (context) {
          // Lấy arguments dưới dạng Map
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
          final email = args['email']!;
          final resetToken = args['resetToken']!;
          return ForgotPasswordNewPassView(
            email: email,
            resetToken: resetToken,
          );
        },
      },
      theme: ThemeData.dark(),
    );
  }
}