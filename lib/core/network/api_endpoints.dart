/// API endpoints configuration.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://dev-api.magnaedu.id/msisms-api';

  // Auth endpoints
  static const String login = '/msisms006/user/login';
  static const String signupParent = '/msisms002-parent/add_account_parent';
  static const String checkEmailUnique = '/msisms002-parent/check_email_unique';
  static const String parentStudents = '/msisms002-parent/get-students';
  static const String parentCandidates = '/msisms002-parent/get-candidates';
  static const String schoolUnits = '/msisms002-parent/get-school-unit';
  static const String schoolLevels = '/msisms002-parent/get-school-level';
  static const String schoolGrades = '/msisms002-parent/get-school-grade';
  static const String currentAcademicYear =
      '/msisms002-parent/get-current-academic-year';
  static const String paymentMethodNonFree =
      '/msisms002-parent/get-payment-method-non-free';
  static const String registrationPrice =
      '/msisms002-parent/get-registration-price';
  static const String addCandidate = '/msisms002-parent/add_candidate';
  static const String checkToken = '/msisms006/user/token';
  static const String checkTokenValid = '/msisms006/user/token-valid';

  // User endpoints
  static const String sidebar = '/msisms006/user/sidebar';
  static const String sendValidation = '/msisms006/user/send-validation';
  static const String updatePassword =
      '/msisms006/user/update-employee-password';
  static const String updateStudentPassword = '/app003/update-student-password';
  static const String parentProfile = '/app003/parent-profile';
  static const String parentProfileUpdate = '/app003/parent-profile-update';
  static const String parentProfileUpload = '/app003/parent-profile-upload';
  static const String parentProfileFile = '/app003/get-file/parent';
  static const String dashboardStudentProfile =
      '/app003/dashboard-student-profile';
  static const String studentDataStudent = '/msisms003/student-data/student';
  static const String studentSchedule =
      '/msisms003/parent-user/get-student-schedule';
  static const String parentCalendar = '/msisms003/parent-user/parent-calendar';
  static const String attendanceChartData = '/msisms003/parent-user/chart-data';
  static const String assessmentStatus =
      '/msisms003/parent-user/assessment-status';
  static const String assessmentMonitoringStatus =
      '/msisms003/parent-user/assessment-monitoring-status';
  static const String assessmentType =
      '/msisms003/parent-user/get-assessment-type';
  static const String pageAccess = '/msisms006/user/page-access';
}
