import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/dashboard/parent/presentation/screens/parent_dashboard_screen.dart';
import '../../features/dashboard/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/students/domain/entities/student.dart';
import '../../features/students/domain/entities/registration_payment_args.dart';
import '../../features/students/presentation/screens/student_detail_screen.dart';
import '../../features/students/presentation/screens/student_list_screen.dart';
import '../../features/students/presentation/screens/student_registration_screen.dart';
import '../../features/students/presentation/screens/student_registration_payment_screen.dart';
import '../../features/guide/presentation/screens/guide_screen.dart';
import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../features/assessment/presentation/screens/assessment_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';
import '../../features/academic_calendar/presentation/screens/academic_calendar_screen.dart';
import '../../features/reports/presentation/screens/attendance_report_screen.dart';
import '../../features/reports/presentation/screens/exam_schedule_screen.dart';
import '../../features/reports/presentation/screens/session_attendance_screen.dart';
import '../../features/reports/presentation/screens/student_progress_screen.dart';
import '../../shared/widgets/navigation/main_shell.dart';

/// Route names for the application.
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Parent routes
  static const String parentDashboard = '/parent/dashboard';
  static const String studentRegistration = '/parent/students/registration';
  static const String studentRegistrationPayment =
      '/parent/students/registration/payment';
  static const String studentList = '/parent/students/list';
  static const String studentDetail = '/parent/students/detail';
  static const String guide = '/parent/guide';
  static const String contactUs = '/parent/contact';
  static const String parentSettings = '/parent/settings';
  static const String parentProfile = '/parent/profile';
  static const String changePassword = '/settings/change-password';

  // Student routes
  static const String studentDashboard = '/student/dashboard';
  static const String assessment = '/student/assessment';
  static const String schedule = '/student/schedule';
  static const String academicCalendar = '/student/academic-calendar';
  static const String attendanceReport = '/student/reports/attendance';
  static const String examSchedule = '/student/reports/exam-schedule';
  static const String sessionAttendance = '/student/reports/session-attendance';
  static const String studentProgress = '/student/reports/progress';
  static const String studentSettings = '/student/settings';
  static const String studentProfile = '/student/profile';

  // Common routes
  static const String notifications = '/notifications';
}

/// Router provider for the application.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final signupSuccess =
              state.uri.queryParameters['signupSuccess'] == '1';
          return LoginScreen(showSignupSuccess: signupSuccess);
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) {
          final loginType = state.uri.queryParameters['loginType'];
          return ForgotPasswordScreen(loginType: loginType);
        },
      ),

      // Parent Shell
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(userType: UserType.parent, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.parentDashboard,
            name: 'parentDashboard',
            builder: (context, state) => const ParentDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.parentSettings,
            name: 'parentSettings',
            builder: (context, state) =>
                const SettingsScreen(userType: UserType.parent),
          ),
        ],
      ),

      // Parent non-shell routes
      GoRoute(
        path: AppRoutes.studentRegistration,
        name: 'studentRegistration',
        builder: (context, state) => const StudentRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentRegistrationPayment,
        name: 'studentRegistrationPayment',
        builder: (context, state) {
          final args = state.extra;
          if (args is! RegistrationPaymentArgs) {
            return const Scaffold(
              body: Center(
                child: Text('Registration payment data is missing.'),
              ),
            );
          }

          return StudentRegistrationPaymentScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.studentList,
        name: 'studentList',
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDetail,
        name: 'studentDetail',
        builder: (context, state) {
          final student = state.extra;
          if (student is! Student) {
            return const Scaffold(
              body: Center(child: Text('Student detail data is missing.')),
            );
          }
          return StudentDetailScreen(student: student);
        },
      ),
      GoRoute(
        path: AppRoutes.guide,
        name: 'guide',
        builder: (context, state) => const GuideScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactUs,
        name: 'contactUs',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentProfile,
        name: 'parentProfile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Student Shell
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(userType: UserType.student, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.studentDashboard,
            name: 'studentDashboard',
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.studentSettings,
            name: 'studentSettings',
            builder: (context, state) =>
                const SettingsScreen(userType: UserType.student),
          ),
        ],
      ),

      // Student non-shell routes
      GoRoute(
        path: AppRoutes.assessment,
        name: 'assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.academicCalendar,
        name: 'academicCalendar',
        builder: (context, state) => const AcademicCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceReport,
        name: 'attendanceReport',
        builder: (context, state) => const AttendanceReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.examSchedule,
        name: 'examSchedule',
        builder: (context, state) => const ExamScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionAttendance,
        name: 'sessionAttendance',
        builder: (context, state) => const SessionAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProgress,
        name: 'studentProgress',
        builder: (context, state) => const StudentProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        name: 'studentProfile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Common routes
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});

/// User type enum for navigation.
enum UserType { parent, student }
