import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'routing/app_router.dart';
import 'shared/providers/shared_providers.dart';
import 'shared/utils/current_user_session_storage.dart';

/// Main application widget.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    ApiClient.registerUnauthorizedHandler(() async {
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
