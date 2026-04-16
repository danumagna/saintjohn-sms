import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/shared_providers.dart';
import '../../../shared/utils/current_user_session_storage.dart';
import '../data/models/academic_calendar_entry.dart';
import '../data/repositories/academic_calendar_repository.dart';

class AcademicCalendarRequest {
  final String id;
  final String loginType;
  final String nidStudent;

  const AcademicCalendarRequest({
    required this.id,
    required this.loginType,
    required this.nidStudent,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AcademicCalendarRequest &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            loginType == other.loginType &&
            nidStudent == other.nidStudent;
  }

  @override
  int get hashCode => Object.hash(id, loginType, nidStudent);
}

final academicCalendarRepositoryProvider = Provider<AcademicCalendarRepository>(
  (ref) => AcademicCalendarRepository(),
);

final parentCalendarProvider =
    FutureProvider.family<List<AcademicCalendarEntry>, AcademicCalendarRequest>(
      (ref, request) async {
        final currentUser = ref.read(currentUserProvider);
        var authToken = currentUser?.userToken?.trim() ?? '';
        if (authToken.isEmpty) {
          final storedUser = await readStoredCurrentUser();
          authToken = storedUser?.userToken?.trim() ?? '';
          if (storedUser != null && ref.read(currentUserProvider) == null) {
            ref.read(currentUserProvider.notifier).state = storedUser;
          }
        }

        final repository = ref.read(academicCalendarRepositoryProvider);
        return repository.getParentCalendar(
          id: request.id,
          loginType: request.loginType,
          nidStudent: request.nidStudent,
          authToken: authToken,
        );
      },
    );
