/// API endpoints configuration.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://dev-api.magnaedu.id/msisms-api';

  // Auth endpoints
  static const String login = '/msisms006/user/login';
  static const String signupParent = '/msisms002-parent/add_account_parent';
  static const String parentStudents = '/msisms002-parent/get-students';
  static const String schoolUnits = '/msisms002-parent/get-school-unit';
  static const String schoolLevels = '/msisms002-parent/get-school-level';
  static const String schoolGrades = '/msisms002-parent/get-school-grade';
  static const String currentAcademicYear =
      '/msisms002-parent/get-current-academic-year';
  static const String paymentMethodNonFree =
      '/msisms002-parent/get-payment-method-non-free';
  static const String checkToken = '/msisms006/user/token';
  static const String checkTokenValid = '/msisms006/user/token-valid';

  // User endpoints
  static const String sidebar = '/msisms006/user/sidebar';
  static const String sendValidation = '/msisms006/user/send-validation';
  static const String updatePassword =
      '/msisms006/user/update-employee-password';
  static const String pageAccess = '/msisms006/user/page-access';
}
