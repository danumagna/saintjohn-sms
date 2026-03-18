// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Saint John SMS';

  @override
  String get appFullName => 'Saint John School Management System';

  @override
  String get authLoginTitle => 'Login';

  @override
  String get authLoginAsParent => 'Login as Parent';

  @override
  String get authLoginAsStudent => 'Login as Student';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authLogin => 'Login';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authSignUpTitle => 'Create Account';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authFullNameLabel => 'Full Name';

  @override
  String get authPhoneHint => 'Enter your phone number';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authConfirmPasswordHint => 'Confirm your password';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authAgreeTerms => 'I agree to the Terms & Conditions';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authForgotPasswordDesc =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get menuStudents => 'Students';

  @override
  String get menuStudentRegistration => 'Registration';

  @override
  String get menuStudentList => 'Student List';

  @override
  String get menuGuide => 'Guide';

  @override
  String get menuContactUs => 'Contact Us';

  @override
  String get menuAssessment => 'Assessment';

  @override
  String get menuSchedule => 'Class Schedule';

  @override
  String get menuAcademicCalendar => 'Academic Calendar';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuAttendance => 'Student Attendance';

  @override
  String get menuExamSchedule => 'Today\'s Exam Schedule';

  @override
  String get menuSessionAttendance => 'Session Attendance Today';

  @override
  String get menuStudentProgress => 'Student Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMyProfile => 'My Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'About App';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonNoData => 'No data available';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Please enter a valid email';

  @override
  String get validationPasswordMin => 'Password must be at least 8 characters';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get validationPhone => 'Please enter a valid phone number';

  @override
  String get studentsListTitle => 'Student List';

  @override
  String get studentsSearchHint => 'Search by name, NIK, or family card number';

  @override
  String get studentsEmptyState => 'No students found';

  @override
  String get studentsRegistrationTitle => 'Student Registration';

  @override
  String get studentsFullName => 'Full Name';

  @override
  String get studentsFullNameHint => 'Enter student full name';

  @override
  String get studentsNISN => 'NISN';

  @override
  String get studentsNISNHint => 'Enter NISN';

  @override
  String get studentsGender => 'Gender';

  @override
  String get studentsBirthDate => 'Birth Date';

  @override
  String get studentsBirthDateHint => 'Select birth date';

  @override
  String get studentsGrade => 'Grade';

  @override
  String get studentsClass => 'Class';

  @override
  String get studentsAddress => 'Address';

  @override
  String get studentsAddressHint => 'Enter student address';

  @override
  String get studentsRegisterButton => 'Register Student';

  @override
  String get guideTitle => 'Guide';

  @override
  String get contactTitle => 'Contact Us';

  @override
  String get contactReachUs => 'Reach Us';

  @override
  String get contactAddress => 'Address';

  @override
  String get contactPhone => 'Phone';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactOfficeHours => 'Office Hours';

  @override
  String get contactSendMessage => 'Send us a Message';

  @override
  String get contactSubject => 'Subject';

  @override
  String get contactSubjectHint => 'Enter message subject';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactMessageHint => 'Enter your message';

  @override
  String get contactSendButton => 'Send Message';

  @override
  String get assessmentTitle => 'Assessment';

  @override
  String get assessmentAll => 'All';

  @override
  String get assessmentExams => 'Exams';

  @override
  String get assessmentAssignments => 'Assignments';

  @override
  String get assessmentAverage => 'Average';

  @override
  String get assessmentTotal => 'Total';

  @override
  String get assessmentRank => 'Rank';

  @override
  String get scheduleTitle => 'Class Schedule';

  @override
  String get calendarTitle => 'Academic Calendar';

  @override
  String get calendarNoEvents => 'No events for this day';

  @override
  String get reportAttendance => 'Attendance Report';

  @override
  String get reportAttendanceRate => 'Attendance Rate';

  @override
  String get reportPresent => 'Present';

  @override
  String get reportAbsent => 'Absent';

  @override
  String get reportLate => 'Late';

  @override
  String get reportExcused => 'Excused';

  @override
  String get reportExamSchedule => 'Exam Schedule';

  @override
  String get reportTodayExams => 'Today\'s Exams';

  @override
  String get reportUpcomingExams => 'Upcoming Exams';

  @override
  String get reportNoExams => 'No exams scheduled';

  @override
  String get reportSessionAttendance => 'Session Attendance';

  @override
  String get reportTodayAttendance => 'Today\'s Attendance';

  @override
  String get reportOngoing => 'Ongoing';

  @override
  String get reportUpcoming => 'Upcoming';

  @override
  String get reportProgress => 'Student Progress';

  @override
  String get reportOverall => 'Overall';

  @override
  String get reportAcademicProgress => 'Academic Progress';

  @override
  String get reportSubjects => 'Subjects';

  @override
  String get reportAvgGrade => 'Avg Grade';

  @override
  String get reportSubjectProgress => 'Subject Progress';

  @override
  String get reportTopics => 'topics';

  @override
  String get reportAchievements => 'Achievements';

  @override
  String get reportTopPerformer => 'Top Performer';

  @override
  String get reportMostImproved => 'Most Improved';
}
