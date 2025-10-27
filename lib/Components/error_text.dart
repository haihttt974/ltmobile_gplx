import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String message;
  const ErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Text(
      message,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}
