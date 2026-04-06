/// API endpoints configuration.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'https://dev-api.magnaedu.id/msisms-api';

  // Auth endpoints
  static const String login = '/msisms006/user/login';
  static const String checkToken = '/msisms006/user/token';
  static const String checkTokenValid = '/msisms006/user/token-valid';

  // User endpoints
  static const String sidebar = '/msisms006/user/sidebar';
  static const String sendValidation = '/msisms006/user/send-validation';
  static const String updatePassword =
      '/msisms006/user/update-employee-password';
  static const String pageAccess = '/msisms006/user/page-access';
}
