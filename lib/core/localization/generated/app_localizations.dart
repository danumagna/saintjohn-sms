import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Saint John SMS'**
  String get appName;

  /// Full application name
  ///
  /// In en, this message translates to:
  /// **'Saint John School Management System'**
  String get appFullName;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTitle;

  /// Login as parent tab
  ///
  /// In en, this message translates to:
  /// **'Login as Parent'**
  String get authLoginAsParent;

  /// Login as student tab
  ///
  /// In en, this message translates to:
  /// **'Login as Student'**
  String get authLoginAsStudent;

  /// Email input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// Email input label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Password input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// Password input label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Remember me checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// Sign up link/button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// Sign up screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignUpTitle;

  /// Sign up as parent option
  ///
  /// In en, this message translates to:
  /// **'Sign up as Parent'**
  String get authSignUpAsParent;

  /// Sign up as student option
  ///
  /// In en, this message translates to:
  /// **'Sign up as Student'**
  String get authSignUpAsStudent;

  /// Full name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// Full name input label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// Parent or guardian full name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter parent/guardian full name'**
  String get authGuardianNameHint;

  /// Parent or guardian full name input label
  ///
  /// In en, this message translates to:
  /// **'Parent/Guardian full name'**
  String get authGuardianNameLabel;

  /// Phone input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneHint;

  /// Phone input label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneLabel;

  /// Parent or guardian phone input hint
  ///
  /// In en, this message translates to:
  /// **'Enter parent/guardian phone number'**
  String get authGuardianPhoneHint;

  /// Parent or guardian phone input label
  ///
  /// In en, this message translates to:
  /// **'Parent/Guardian phone number'**
  String get authGuardianPhoneLabel;

  /// Parent or guardian email input hint
  ///
  /// In en, this message translates to:
  /// **'Enter parent/guardian email address'**
  String get authGuardianEmailHint;

  /// Parent or guardian email input label
  ///
  /// In en, this message translates to:
  /// **'Parent/Guardian email address'**
  String get authGuardianEmailLabel;

  /// Confirm email input hint
  ///
  /// In en, this message translates to:
  /// **'Retype email address'**
  String get authConfirmEmailHint;

  /// Confirm email input label
  ///
  /// In en, this message translates to:
  /// **'Retype email address'**
  String get authConfirmEmailLabel;

  /// Retype password input hint
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get authRetypePasswordHint;

  /// Retype password input label
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get authRetypePasswordLabel;

  /// Confirm password input hint
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get authConfirmPasswordHint;

  /// Confirm password input label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// Terms agreement checkbox
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions'**
  String get authAgreeTerms;

  /// Have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// Forgot password description
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get authForgotPasswordDesc;

  /// Send reset link button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authSendResetLink;

  /// Back to login link
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// Welcome message with name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dashboardWelcome(String name);

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Average score label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Avg. Score'**
  String get dashboardAverageScore;

  /// Classes today label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Classes Today'**
  String get dashboardClassesToday;

  /// Attendance rate label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get dashboardAttendanceRate;

  /// Exams today label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Exams Today'**
  String get dashboardExamsToday;

  /// Sessions attended label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Sessions Attended'**
  String get dashboardSessionsAttended;

  /// Overall progress label in dashboard summary
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get dashboardOverallProgress;

  /// Section title for dashboard summary cards
  ///
  /// In en, this message translates to:
  /// **'Today Summary'**
  String get dashboardSummarySectionTitle;

  /// Section title for dashboard main menu cards
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get dashboardMainMenuSectionTitle;

  /// Students menu
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get menuStudents;

  /// Student registration submenu
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get menuStudentRegistration;

  /// Student list submenu
  ///
  /// In en, this message translates to:
  /// **'Student List'**
  String get menuStudentList;

  /// Guide menu
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get menuGuide;

  /// Contact us menu
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get menuContactUs;

  /// Assessment menu
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get menuAssessment;

  /// Class schedule menu
  ///
  /// In en, this message translates to:
  /// **'Class Schedule'**
  String get menuSchedule;

  /// Academic calendar menu
  ///
  /// In en, this message translates to:
  /// **'Academic Calendar'**
  String get menuAcademicCalendar;

  /// Reports menu
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// Attendance report
  ///
  /// In en, this message translates to:
  /// **'Student Attendance'**
  String get menuAttendance;

  /// Exam schedule menu
  ///
  /// In en, this message translates to:
  /// **'Today\'s Exam Schedule'**
  String get menuExamSchedule;

  /// Session attendance menu
  ///
  /// In en, this message translates to:
  /// **'Session Attendance Today'**
  String get menuSessionAttendance;

  /// Student progress menu
  ///
  /// In en, this message translates to:
  /// **'Student Progress'**
  String get menuStudentProgress;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// My profile menu
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get settingsMyProfile;

  /// Language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Notification settings
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// About app menu
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAbout;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogoutConfirm;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Empty notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// Mark all as read button
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// Email validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmail;

  /// Confirm email validation
  ///
  /// In en, this message translates to:
  /// **'Email addresses do not match'**
  String get validationEmailMatch;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMin;

  /// Password match validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMatch;

  /// Phone validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validationPhone;

  /// Student list screen title
  ///
  /// In en, this message translates to:
  /// **'Student List'**
  String get studentsListTitle;

  /// Student search hint
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get studentsSearchHint;

  /// Empty students message
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get studentsEmptyState;

  /// Student registration screen title
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get studentsRegistrationTitle;

  /// Student full name label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get studentsFullName;

  /// Student full name hint
  ///
  /// In en, this message translates to:
  /// **'Enter student full name'**
  String get studentsFullNameHint;

  /// NISN label
  ///
  /// In en, this message translates to:
  /// **'NISN'**
  String get studentsNISN;

  /// NISN hint
  ///
  /// In en, this message translates to:
  /// **'Enter NISN'**
  String get studentsNISNHint;

  /// Gender label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get studentsGender;

  /// Birth date label
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get studentsBirthDate;

  /// Birth date hint
  ///
  /// In en, this message translates to:
  /// **'Select birth date'**
  String get studentsBirthDateHint;

  /// Grade label
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentsGrade;

  /// Class label
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get studentsClass;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get studentsAddress;

  /// Address hint
  ///
  /// In en, this message translates to:
  /// **'Enter student address'**
  String get studentsAddressHint;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register Student'**
  String get studentsRegisterButton;

  /// Guide screen title
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guideTitle;

  /// Contact screen title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// Reach us section title
  ///
  /// In en, this message translates to:
  /// **'Reach Us'**
  String get contactReachUs;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get contactAddress;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// Office hours label
  ///
  /// In en, this message translates to:
  /// **'Office Hours'**
  String get contactOfficeHours;

  /// Send message section title
  ///
  /// In en, this message translates to:
  /// **'Send us a Message'**
  String get contactSendMessage;

  /// Subject label
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactSubject;

  /// Subject hint
  ///
  /// In en, this message translates to:
  /// **'Enter message subject'**
  String get contactSubjectHint;

  /// Message label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// Message hint
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get contactMessageHint;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactSendButton;

  /// Assessment screen title
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessmentTitle;

  /// All tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get assessmentAll;

  /// Exams tab
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get assessmentExams;

  /// Assignments tab
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assessmentAssignments;

  /// Average score label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get assessmentAverage;

  /// Total assessments label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get assessmentTotal;

  /// Rank label
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get assessmentRank;

  /// Schedule screen title
  ///
  /// In en, this message translates to:
  /// **'Class Schedule'**
  String get scheduleTitle;

  /// Calendar screen title
  ///
  /// In en, this message translates to:
  /// **'Academic Calendar'**
  String get calendarTitle;

  /// No events message
  ///
  /// In en, this message translates to:
  /// **'No events for this day'**
  String get calendarNoEvents;

  /// Attendance report title
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get reportAttendance;

  /// Attendance rate label
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get reportAttendanceRate;

  /// Present status
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get reportPresent;

  /// Absent status
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get reportAbsent;

  /// Late status
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get reportLate;

  /// Excused status
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get reportExcused;

  /// Exam schedule title
  ///
  /// In en, this message translates to:
  /// **'Exam Schedule'**
  String get reportExamSchedule;

  /// Today's exams label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Exams'**
  String get reportTodayExams;

  /// Upcoming exams label
  ///
  /// In en, this message translates to:
  /// **'Upcoming Exams'**
  String get reportUpcomingExams;

  /// No exams message
  ///
  /// In en, this message translates to:
  /// **'No exams scheduled'**
  String get reportNoExams;

  /// Session attendance title
  ///
  /// In en, this message translates to:
  /// **'Session Attendance'**
  String get reportSessionAttendance;

  /// Today's attendance label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Attendance'**
  String get reportTodayAttendance;

  /// Ongoing status
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get reportOngoing;

  /// Upcoming status
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get reportUpcoming;

  /// Progress report title
  ///
  /// In en, this message translates to:
  /// **'Student Progress'**
  String get reportProgress;

  /// Overall label
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get reportOverall;

  /// Academic progress label
  ///
  /// In en, this message translates to:
  /// **'Academic Progress'**
  String get reportAcademicProgress;

  /// Subjects label
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get reportSubjects;

  /// Average grade label
  ///
  /// In en, this message translates to:
  /// **'Avg Grade'**
  String get reportAvgGrade;

  /// Subject progress section title
  ///
  /// In en, this message translates to:
  /// **'Subject Progress'**
  String get reportSubjectProgress;

  /// Topics label
  ///
  /// In en, this message translates to:
  /// **'topics'**
  String get reportTopics;

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get reportAchievements;

  /// Top performer achievement
  ///
  /// In en, this message translates to:
  /// **'Top Performer'**
  String get reportTopPerformer;

  /// Most improved achievement
  ///
  /// In en, this message translates to:
  /// **'Most Improved'**
  String get reportMostImproved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
