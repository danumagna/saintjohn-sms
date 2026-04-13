class RegistrationPaymentArgs {
  final String fullName;
  final String schoolLevel;
  final String className;
  final String schoolName;
  final Map<String, dynamic> registrationPricePayload;

  const RegistrationPaymentArgs({
    required this.fullName,
    required this.schoolLevel,
    required this.className,
    required this.schoolName,
    required this.registrationPricePayload,
  });
}
