import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user.dart';

const String _currentUserStorageKey = 'current_user_session';
const String _rememberMeStorageKey = 'remember_me_enabled';

Future<void> saveCurrentUserSession(User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_currentUserStorageKey, jsonEncode(_userToJson(user)));
}

Future<void> saveRememberMeEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_rememberMeStorageKey, enabled);
}

Future<bool> readRememberMeEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_rememberMeStorageKey) ?? true;
}

Future<User?> readStoredCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_currentUserStorageKey);
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return _userFromJson(decoded);
  } catch (_) {
    return null;
  }
}

Future<void> clearCurrentUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_currentUserStorageKey);
}

Future<void> saveCurrentUserSessionIfRemembered(User user) async {
  final rememberMeEnabled = await readRememberMeEnabled();
  if (!rememberMeEnabled) {
    return;
  }

  await saveCurrentUserSession(user);
}

Map<String, dynamic> _userToJson(User user) {
  return <String, dynamic>{
    'id': user.id,
    'fullName': user.fullName,
    'email': user.email,
    'phone': user.phone,
    'role': user.role,
    'avatarUrl': user.avatarUrl,
    'grade': user.grade,
    'className': user.className,
    'birthDate': user.birthDate,
    'dream': user.dream,
    'schoolName': user.schoolName,
    'classId': user.classId,
    'createdAt': user.createdAt.toIso8601String(),
    'userToken': user.userToken,
    'userTokenExpiry': user.userTokenExpiry?.toIso8601String(),
    'studentId': user.studentId,
    'childrenStudentId': user.childrenStudentId,
  };
}

User _userFromJson(Map<String, dynamic> json) {
  final children = json['childrenStudentId'];
  final childrenIds = children is List
      ? children
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toList()
      : null;

  return User(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
    avatarUrl: json['avatarUrl']?.toString(),
    grade: json['grade']?.toString(),
    className: json['className']?.toString(),
    birthDate: json['birthDate']?.toString(),
    dream: json['dream']?.toString(),
    schoolName: json['schoolName']?.toString(),
    classId: int.tryParse(json['classId']?.toString() ?? ''),
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    userToken: json['userToken']?.toString(),
    userTokenExpiry: DateTime.tryParse(
      json['userTokenExpiry']?.toString() ?? '',
    ),
    studentId: int.tryParse(json['studentId']?.toString() ?? ''),
    childrenStudentId: childrenIds,
  );
}
