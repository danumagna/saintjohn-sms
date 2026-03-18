import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user.dart';

/// User type enum.
enum UserType { parent, student }

/// Current user provider.
final currentUserProvider = StateProvider<User?>((ref) => null);

/// User type provider based on current user.
final userTypeProvider = Provider<UserType?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return user.role == 'parent' ? UserType.parent : UserType.student;
});

/// Locale provider for internationalization.
final localeProvider = StateProvider<String>((ref) => 'en');

/// Theme mode provider (for future dark mode support).
final themeModeProvider = StateProvider<bool>((ref) => false);

/// Notification toggle provider for settings screen.
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
