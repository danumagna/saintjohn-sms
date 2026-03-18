/// Application animation durations and delays.
class AppDurations {
  AppDurations._();

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Specific Durations
  static const Duration splash = Duration(seconds: 3);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration buttonPress = Duration(milliseconds: 150);
  static const Duration snackbar = Duration(seconds: 3);
  static const Duration shimmer = Duration(milliseconds: 1500);

  // Delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration debounce = Duration(milliseconds: 500);
  static const Duration throttle = Duration(milliseconds: 1000);
}
