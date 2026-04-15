import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/shared_providers.dart';
import '../data/models/student_schedule_item.dart';
import '../data/repositories/schedule_repository.dart';

/// Schedule repository provider.
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

/// Fetches student schedule grouped by day from API.
final studentScheduleProvider =
    FutureProvider.family<Map<int, List<StudentScheduleItem>>, int>((
      ref,
      nidSchoolClass,
    ) async {
      final currentUser = ref.read(currentUserProvider);
      final authToken = currentUser?.userToken?.trim() ?? '';

      final repository = ref.read(scheduleRepositoryProvider);
      return repository.getStudentSchedule(
        nidSchoolClass: nidSchoolClass.toString(),
        authToken: authToken,
      );
    });
