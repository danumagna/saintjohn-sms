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
        final storedUser = await readStoredCurrentUser();
        final currentToken = currentUser?.userToken?.trim() ?? '';
        final storedToken = storedUser?.userToken?.trim() ?? '';

        if (storedUser != null && ref.read(currentUserProvider) == null) {
          ref.read(currentUserProvider.notifier).state = storedUser;
        }

        final repository = ref.read(academicCalendarRepositoryProvider);
        final tokenCandidates = <String>{
          if (currentToken.isNotEmpty) currentToken,
          if (storedToken.isNotEmpty) storedToken,
        }.toList();

        if (tokenCandidates.isEmpty) {
          throw const AcademicCalendarException(
            'Session expired. Please login again.',
          );
        }

        AcademicCalendarException? lastAuthDenied;
        for (final token in tokenCandidates) {
          try {
            return await repository.getParentCalendar(
              id: request.id,
              loginType: request.loginType,
              nidStudent: request.nidStudent,
              authToken: token,
            );
          } on AcademicCalendarException catch (e) {
            final text = e.message.toLowerCase();
            final isAuthIssue =
                text.contains('auth') ||
                text.contains('unauthor') ||
                text.contains('session') ||
                text.contains('access');
            if (isAuthIssue) {
              lastAuthDenied = e;
              continue;
            }
            rethrow;
          }
        }

        if (lastAuthDenied != null) {
          throw lastAuthDenied;
        }

        throw const AcademicCalendarException(
          'Failed to load academic calendar.',
        );
      },
    );
