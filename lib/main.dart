import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/constants/app_colors.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Ensure DateFormat with explicit locales (for example id_ID) works.
      await Future.wait<void>([
        initializeDateFormatting('id_ID'),
        initializeDateFormatting('en'),
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      runApp(const ProviderScope(child: App()));
    },
    (Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('[zoned_error] $error');
        debugPrintStack(stackTrace: stack);
      }
    },
  );
}
