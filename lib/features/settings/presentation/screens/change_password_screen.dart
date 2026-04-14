import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String _newPasswordValue = '';

  static final RegExp _upperCaseRegex = RegExp(r'[A-Z]');
  static final RegExp _symbolRegex = RegExp(r'[^A-Za-z0-9]');
  static const String _passwordUsedMessage =
      '1. Pastikan password yang dimasukan benar\n\n 2. Password baru yang dimasukkan berbeda dengan password lama.';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _hasMinLength(String value) => value.length >= 8;

  bool _hasUpperCase(String value) => _upperCaseRegex.hasMatch(value);

  bool _hasSymbol(String value) => _symbolRegex.hasMatch(value);

  int _passwordStrengthScore(String value) {
    if (value.isEmpty) return 0;

    var score = 0;
    if (_hasMinLength(value)) score++;
    if (_hasUpperCase(value)) score++;
    if (_hasSymbol(value)) score++;

    return score;
  }

  ({String label, Color color}) _passwordStrengthMeta(String value) {
    final score = _passwordStrengthScore(value);
    if (score <= 1) {
      return (label: 'Lemah', color: AppColors.error);
    }
    if (score == 2) {
      return (label: 'Sedang', color: AppColors.warning);
    }
    return (label: 'Kuat', color: AppColors.success);
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text(
          'Informasi',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    final userId = int.tryParse(user?.id ?? '');
    final authToken = user?.userToken?.trim() ?? '';

    if (userId == null) {
      await _showErrorDialog('User ID tidak valid.');
      return;
    }

    if (authToken.isEmpty) {
      await _showErrorDialog('Session berakhir. Silakan login ulang.');
      return;
    }

    _apiClient.setAuthToken(authToken);

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.post(
        ApiEndpoints.updateStudentPassword,
        data: <String, dynamic>{
          // Keep both keys for backend compatibility.
          'nuserId': userId,
          'nid': userId,
          'vstudentDashboardOldPassword': _currentPasswordController.text,
          'vstudentDashboardNewPassword': _newPasswordController.text,
        },
        options: Options(headers: <String, dynamic>{'AUTHTOKEN': authToken}),
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      final status = body['status']?.toString();
      if (status != '1') {
        final message = body['message'];
        if (message is Map<String, dynamic>) {
          final errorMessage =
              message['errmsg']?.toString() ??
              message['msg']?.toString() ??
              message['message']?.toString();
          if (errorMessage != null && errorMessage.isNotEmpty) {
            throw Exception(errorMessage);
          }
        }
        throw Exception(_passwordUsedMessage);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diperbarui.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is Map<String, dynamic>) {
          final errorMessage =
              message['errmsg']?.toString() ??
              message['msg']?.toString() ??
              message['message']?.toString();
          if (errorMessage != null && errorMessage.isNotEmpty) {
            await _showErrorDialog(errorMessage);
            return;
          }
        }
      }
      await _showErrorDialog(_passwordUsedMessage);
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  hint: 'Masukkan password saat ini',
                  obscureText: true,
                  prefixIcon: Iconsax.lock,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'Masukkan password baru',
                  obscureText: true,
                  prefixIcon: Iconsax.lock_1,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    setState(() {
                      _newPasswordValue = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field wajib diisi';
                    }
                    if (!_hasMinLength(value) ||
                        !_hasUpperCase(value) ||
                        !_hasSymbol(value)) {
                      return 'Kata sandi belum memenuhi kriteria.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kata sandi harus terdiri dari minimal 8 karakter, '
                    'memiliki 1 huruf kapital, dan 1 simbol.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (_newPasswordValue.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingS),
                  Builder(
                    builder: (context) {
                      final score = _passwordStrengthScore(_newPasswordValue);
                      final strength = _passwordStrengthMeta(_newPasswordValue);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS,
                            ),
                            child: LinearProgressIndicator(
                              value: score / 3,
                              minHeight: 6,
                              backgroundColor: AppColors.borderLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                strength.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            'Kekuatan kata sandi: ${strength.label}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: strength.color,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Ulangi password baru',
                  obscureText: true,
                  prefixIcon: Iconsax.lock,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field wajib diisi';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak sama';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                PrimaryButton(
                  text: 'Simpan Password',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
