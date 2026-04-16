import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'routing/app_router.dart';
import 'shared/providers/shared_providers.dart';
import 'shared/utils/current_user_session_storage.dart';

/// Main application widget.
class App extends ConsumerWidget {
  const App({super.key});

  Future<void> _showSessionExpiredDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sesi Berakhir',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Sesi login Anda sudah habis. Silakan login kembali untuk '
            'melanjutkan.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Login Kembali'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    ApiClient.registerUnauthorizedHandler(() async {
      final rootContext = router.routerDelegate.navigatorKey.currentContext;
      if (rootContext != null) {
        await _showSessionExpiredDialog(rootContext);
      }

      ref.read(authRepositoryProvider).logout();
      await clearCurrentUserSession();

      ref.read(currentUserProvider.notifier).state = null;
      ref.read(currentUserPhotoBytesProvider.notifier).state = null;

      router.go(AppRoutes.login);
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Saint John SMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
