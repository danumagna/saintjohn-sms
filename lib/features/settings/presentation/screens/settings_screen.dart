import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../shared/data/dummy/dummy_users.dart';
import '../../../../shared/providers/shared_providers.dart' hide UserType;
import '../../../../shared/utils/current_user_session_storage.dart';
import '../../../../shared/widgets/avatar/user_profile_avatar.dart';
import '../../../../shared/widgets/cards/menu_card.dart';

/// Settings screen for both parent and student users.
class SettingsScreen extends ConsumerWidget {
  final UserType userType;

  const SettingsScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user =
        ref.watch(currentUserProvider) ??
        (userType == UserType.parent
            ? DummyUsers.getDefaultParent()
            : DummyUsers.getDefaultStudent());
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                    l10n.settingsTitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .slideY(begin: -0.2, end: 0),
              const SizedBox(height: AppDimensions.paddingXL),
              // Profile Card
              Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        UserProfileAvatar(
                          user: user,
                          size: 60,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          textColor: AppColors.primary,
                          fontSize: 24,
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (userType == UserType.parent) {
                              context.push(AppRoutes.parentProfile);
                            } else {
                              context.push(AppRoutes.studentProfile);
                            }
                          },
                          icon: const Icon(
                            Iconsax.edit,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 400),
                  )
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppDimensions.paddingXL),
              // Menu Items
              MenuListItem(
                title: 'Change Password',
                icon: Iconsax.lock,
                onTap: () => context.push(AppRoutes.changePassword),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
              ),
              MenuListItem(
                title: l10n.settingsNotifications,
                icon: Iconsax.notification,
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    ref.read(notificationsEnabledProvider.notifier).state =
                        value;
                  },
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return null;
                  }),
                ),
                showArrow: false,
                onTap: () {
                  ref.read(notificationsEnabledProvider.notifier).state =
                      !notificationsEnabled;
                },
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 450),
                duration: const Duration(milliseconds: 400),
              ),
              MenuListItem(
                title: l10n.settingsAbout,
                subtitle: 'Version 1.0.0',
                icon: Iconsax.info_circle,
                onTap: () => _showAboutDialog(context),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              // Logout Button
              MenuListItem(
                title: l10n.settingsLogout,
                icon: Iconsax.logout,
                iconColor: AppColors.error,
                showArrow: false,
                onTap: () => _showLogoutDialog(context, ref, l10n),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text(
          'Saint John SMS',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saint John School Management System',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.paddingS),
            Text(
              '© 2026 Saint John School',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.logout,
                    color: AppColors.error,
                    size: 26,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  l10n.settingsLogout,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  l10n.settingsLogoutConfirm,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: BorderSide(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.commonNo,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          ref.read(authRepositoryProvider).logout();
                          await clearCurrentUserSession();

                          if (!context.mounted) {
                            return;
                          }

                          ref.read(currentUserProvider.notifier).state = null;
                          ref
                                  .read(currentUserPhotoBytesProvider.notifier)
                                  .state =
                              null;
                          context.go(AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textOnPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.commonYes,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}
