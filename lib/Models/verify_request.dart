class VerifyRequest {
  final String email;
  final String otpCode;

  VerifyRequest({required this.email, required this.otpCode});

  Map<String, dynamic> toJson() => {
    "email": email,
    "otpCode": otpCode,
  };
}
