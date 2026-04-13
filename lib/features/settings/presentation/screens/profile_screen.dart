import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Profile screen for editing user information.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _addressController;
  late TextEditingController _nationalityController;
  late TextEditingController _religionController;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;
  bool _isFetchingProfile = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _birthDateController = TextEditingController();
    _placeOfBirthController = TextEditingController();
    _addressController = TextEditingController();
    _nationalityController = TextEditingController(text: 'indonesia');
    _religionController = TextEditingController();

    _prefillProfileFromApi();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _placeOfBirthController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _religionController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedBirthDate = picked;
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _prefillProfileFromApi() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    setState(() => _isFetchingProfile = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final candidateIds = <String>{
        user.id,
        ...?user.childrenStudentId?.map((e) => e.toString()),
      }.where((id) => id.trim().isNotEmpty).toList();

      Map<String, String>? profile;
      for (final id in candidateIds) {
        try {
          final result = await authRepository.getParentProfile(parentId: id);
          profile = result;
          break;
        } on AuthException {
          continue;
        }
      }

      if (!mounted || profile == null) {
        return;
      }

      _nameController.text = profile['name']!.isNotEmpty
          ? profile['name']!
          : _nameController.text;
      _emailController.text = profile['email']!.isNotEmpty
          ? profile['email']!
          : _emailController.text;
      _phoneController.text = profile['phone']!.isNotEmpty
          ? profile['phone']!
          : _phoneController.text;
      _birthDateController.text = profile['dateOfBirth'] ?? '';
      _placeOfBirthController.text = profile['placeOfBirth'] ?? '';
      _addressController.text = profile['address'] ?? '';
      _nationalityController.text =
          (profile['nationality']?.isNotEmpty ?? false)
          ? profile['nationality']!
          : _nationalityController.text;
      _religionController.text = profile['religion'] ?? '';

      final dobText = _birthDateController.text.trim();
      if (dobText.isNotEmpty) {
        _selectedBirthDate = DateTime.tryParse(dobText);
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingProfile = false);
      }
    }
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final message = await authRepository.updateParentProfile(
        parentId: user.id,
        parentName: _nameController.text.trim(),
        parentEmail: _emailController.text.trim(),
        parentPhone: _phoneController.text.trim(),
        parentDateOfBirth: _birthDateController.text.trim(),
        parentPlaceOfBirth: _placeOfBirthController.text.trim(),
        parentAddress: _addressController.text.trim(),
        parentNationality: _nationalityController.text.trim(),
        parentReligion: _religionController.text.trim(),
      );

      if (!mounted) return;

      ref.read(currentUserProvider.notifier).state = user.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.settingsMyProfile),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Text(
              l10n.commonError,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsMyProfile),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isFetchingProfile) ...[
                  const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: AppDimensions.paddingM),
                ],
                Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: AppDimensions.paddingXL),
                AppTextField(
                      controller: _nameController,
                      label: l10n.authGuardianNameLabel,
                      hint: l10n.authGuardianNameHint,
                      prefixIcon: Iconsax.user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _emailController,
                      label: l10n.authGuardianEmailLabel,
                      hint: l10n.authGuardianEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Iconsax.sms,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.validationEmail;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _phoneController,
                      label: l10n.authGuardianPhoneLabel,
                      hint: l10n.authGuardianPhoneHint,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Iconsax.call,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _birthDateController,
                      label: l10n.studentsBirthDate,
                      hint: l10n.studentsBirthDateHint,
                      readOnly: true,
                      prefixIcon: Iconsax.calendar,
                      onTap: _selectBirthDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 450),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _placeOfBirthController,
                      label: 'Place of Birth',
                      hint: 'Enter place of birth',
                      prefixIcon: Iconsax.location,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _addressController,
                      label: l10n.studentsAddress,
                      hint: l10n.studentsAddressHint,
                      prefixIcon: Iconsax.location,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 550),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _nationalityController,
                      label: 'Nationality',
                      hint: 'Enter nationality',
                      prefixIcon: Iconsax.global,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingM),
                AppTextField(
                      controller: _religionController,
                      label: 'Religion',
                      hint: 'Enter religion',
                      prefixIcon: Iconsax.book,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationRequired;
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 650),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppDimensions.paddingXXL),
                PrimaryButton(
                  text: l10n.commonSave,
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 700),
                  duration: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
