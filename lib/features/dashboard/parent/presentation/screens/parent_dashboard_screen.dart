import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../shared/data/dummy/dummy_users.dart';
import '../../../../../shared/providers/shared_providers.dart';
import '../../../../../shared/utils/current_user_session_storage.dart';
import '../../../../../shared/widgets/avatar/user_profile_avatar.dart';
import '../../../../../shared/widgets/cards/menu_card.dart';
import '../../../../../shared/widgets/loading/shimmer_loading.dart';

/// Parent dashboard screen.
class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  static const Duration _profileSyncTtl = Duration(minutes: 2);
  static DateTime? _lastProfileSyncAt;
  static String? _lastProfileSyncParentId;

  bool _isProfileSyncInProgress = false;
  String? _lastSyncParentId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_syncParentProfile);
  }

  bool _isProfileSyncStale(String parentId) {
    if (_lastProfileSyncParentId != parentId) {
      return true;
    }

    final lastSyncAt = _lastProfileSyncAt;
    if (lastSyncAt == null) {
      return true;
    }

    return DateTime.now().difference(lastSyncAt) >= _profileSyncTtl;
  }

  Future<void> _syncParentProfile({bool force = false}) async {
    if (_isProfileSyncInProgress) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || !user.isParent) {
      return;
    }

    final parentId = user.id.trim();
    if (parentId.isEmpty) {
      return;
    }

    if (!force && !_isProfileSyncStale(parentId)) {
      return;
    }

    _lastSyncParentId = parentId;
    if (mounted) {
      setState(() => _isProfileSyncInProgress = true);
    } else {
      _isProfileSyncInProgress = true;
    }

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final token = user.userToken?.trim() ?? '';
      if (token.isNotEmpty) {
        authRepository.setAuthToken(token);
      }

      Map<String, String>? profile;
      try {
        profile = await authRepository.getParentProfile(parentId: parentId);
      } catch (_) {
        profile = null;
      }

      final rawPhotoUrl = profile?['photoUrl']?.trim() ?? '';
      final rawPhotoFilePath = profile?['photoFilePath']?.trim() ?? '';
      final updatedUser = user.copyWith(
        fullName: profile?['name']?.trim().isNotEmpty == true
            ? profile!['name']!.trim()
            : user.fullName,
        email: profile?['email']?.trim().isNotEmpty == true
            ? profile!['email']!.trim()
            : user.email,
        phone: profile?['phone']?.trim().isNotEmpty == true
            ? profile!['phone']!.trim()
            : user.phone,
        avatarUrl: rawPhotoUrl.isNotEmpty
            ? _appendCacheBust(rawPhotoUrl)
            : user.avatarUrl,
      );

      ref.read(currentUserProvider.notifier).state = updatedUser;
      await saveCurrentUserSessionIfRemembered(updatedUser);

      final bytes = await authRepository.getParentProfilePhotoBytes(
        parentId: parentId,
        cacheBust: DateTime.now().millisecondsSinceEpoch,
        filePath: rawPhotoFilePath.isNotEmpty ? rawPhotoFilePath : rawPhotoUrl,
      );

      if (bytes != null) {
        ref.read(currentUserPhotoBytesProvider.notifier).state = bytes;
      } else if (rawPhotoUrl.isNotEmpty) {
        ref.read(currentUserPhotoBytesProvider.notifier).state = null;
      }
    } catch (_) {
      // Keep dashboard usable when profile sync fails.
    } finally {
      _lastProfileSyncParentId = parentId;
      _lastProfileSyncAt = DateTime.now();
      if (mounted) {
        setState(() => _isProfileSyncInProgress = false);
      } else {
        _isProfileSyncInProgress = false;
      }
    }
  }

  String _appendCacheBust(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final separator = trimmed.contains('?') ? '&' : '?';
    return '$trimmed${separator}t=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider) ?? DummyUsers.getDefaultParent();
    final isDashboardBootstrapping = _isProfileSyncInProgress;

    if (user.isParent) {
      final parentId = user.id.trim();
      final shouldSync =
          parentId.isNotEmpty &&
          !_isProfileSyncInProgress &&
          (_lastSyncParentId != parentId || _isProfileSyncStale(parentId));
      if (shouldSync) {
        Future<void>.microtask(_syncParentProfile);
      }
    }

    final firstName = user.fullName.trim().isEmpty
        ? 'Login as Parent'
        : user.fullName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    // Avatar
                    if (isDashboardBootstrapping)
                      const ShimmerLoading(
                        width: 50,
                        height: 50,
                        borderRadius: AppDimensions.radiusCircular,
                      )
                    else
                      UserProfileAvatar(
                            user: user,
                            size: 50,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            textColor: AppColors.primary,
                            fontSize: 20,
                            fallbackLetter: 'P',
                          )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 400))
                          .scale(begin: const Offset(0.5, 0.5)),
                    const SizedBox(width: AppDimensions.paddingM),
                    // Welcome Text
                    Expanded(
                      child: isDashboardBootstrapping
                          ? const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLoading(width: 180, height: 18),
                                SizedBox(height: AppDimensions.paddingS),
                                ShimmerLoading(width: 120, height: 13),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                      'Welcome, $firstName',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: const Duration(milliseconds: 100),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                    )
                                    .slideX(begin: 0.1, end: 0),
                                Text(
                                  'Login as Parent',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ).animate().fadeIn(
                                  delay: const Duration(milliseconds: 200),
                                  duration: const Duration(milliseconds: 400),
                                ),
                              ],
                            ),
                    ),
                    // Notification Icon
                    if (isDashboardBootstrapping)
                      const ShimmerLoading(
                        width: 44,
                        height: 44,
                        borderRadius: AppDimensions.radiusM,
                      )
                    else
                      IconButton(
                        onPressed: () => context.push(AppRoutes.notifications),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                        icon: Stack(
                          children: [
                            const Icon(
                              Iconsax.notification,
                              color: AppColors.textPrimary,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 400),
                      ),
                  ],
                ),
              ),
            ),
            // Menu Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingM,
                  mainAxisSpacing: AppDimensions.paddingM,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildListDelegate(
                  isDashboardBootstrapping
                      ? List<Widget>.generate(
                          3,
                          (_) => const ShimmerLoading(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: AppDimensions.radiusL,
                          ),
                        )
                      : [
                          // Students Menu
                          MenuCard(
                            title: 'Students',
                            icon: Iconsax.people,
                            iconColor: AppColors.primary,
                            index: 0,
                            onTap: () => _showStudentsBottomSheet(context),
                          ),
                          // Guide Menu
                          MenuCard(
                            title: 'Guide',
                            icon: Iconsax.book,
                            iconColor: AppColors.info,
                            index: 1,
                            onTap: () => context.push(AppRoutes.guide),
                          ),
                          // Contact Us Menu
                          MenuCard(
                            title: 'Contact Us',
                            icon: Iconsax.call,
                            iconColor: AppColors.success,
                            index: 2,
                            onTap: () => context.push(AppRoutes.contactUs),
                          ),
                        ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingXL),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Students',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(Iconsax.add_circle, color: AppColors.primary),
              ),
              title: Text(
                'Registration',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.studentRegistration);
              },
            ),
            const SizedBox(height: AppDimensions.paddingS),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(Iconsax.people, color: AppColors.secondary),
              ),
              title: Text(
                'Student List',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.studentList);
              },
            ),
            const SizedBox(height: AppDimensions.paddingL),
          ],
        ),
      ),
    );
  }
}
