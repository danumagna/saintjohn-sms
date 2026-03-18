import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/student.dart';
import '../../providers/students_provider.dart';

/// Student list screen showing all registered students.
class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final students = ref.watch(studentsProvider);
    final filteredStudents = _searchQuery.isEmpty
        ? students
        : students
              .where(
                (student) =>
                    student.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    student.nik.contains(_searchQuery) ||
                    student.familyCardNumber.contains(_searchQuery),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.studentsListTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: AppTextField(
              controller: _searchController,
              hint: l10n.studentsSearchHint,
              prefixIcon: Iconsax.search_normal,
              onChanged: _filterStudents,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          // Student List
          Expanded(
            child: filteredStudents.isEmpty
                ? _buildEmptyState(l10n)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return _buildStudentCard(student, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.user_search,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            l10n.studentsEmptyState,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: InkWell(
            onTap: () => _showStudentDetails(student),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  _buildStudentAvatar(
                    student: student,
                    size: 50,
                    fallbackFontSize: 20,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          'NIK: ${student.nik}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.schoolLevel} - ${student.className}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: student.status == 'Active'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Text(
                      student.status,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: student.status == 'Active'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: 0.1, end: 0);
  }

  void _showStudentDetails(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            _buildStudentAvatar(
              student: student,
              size: 80,
              fallbackFontSize: 32,
              isCircle: true,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              student.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            _buildDetailRow('Tahun Ajaran', student.academicYear),
            _buildDetailRow('Nomor Kartu Keluarga', student.familyCardNumber),
            _buildDetailRow('NIK', student.nik),
            _buildDetailRow('Nama Lengkap', student.fullName),
            _buildDetailRow(
              'Tanggal Lahir',
              '${student.birthDate.day}/${student.birthDate.month}/${student.birthDate.year}',
            ),
            _buildDetailRow('Jenis Kelamin', student.gender),
            _buildDetailRow('Tingkat Sekolah', student.schoolLevel),
            _buildDetailRow('Kelas', student.className),
            _buildDetailRow('Sekolah', student.schoolName),
            _buildDetailRow('Nomor Telp Orang Tua', student.parentPhoneNumber),
            _buildDetailRow('Metode Pembayaran', student.paymentMethod),
            _buildDetailRow('Status', student.status),
            const SizedBox(height: AppDimensions.paddingL),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAvatar({
    required Student student,
    required double size,
    required double fallbackFontSize,
    BorderRadius? borderRadius,
    bool isCircle = false,
  }) {
    final avatarPath = student.avatarUrl?.trim();
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppDimensions.radiusM)),
      ),
      child: !hasAvatar
          ? _buildAvatarFallback(student, fallbackFontSize)
          : avatarPath.startsWith('assets/')
          ? Image.asset(
              avatarPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(student, fallbackFontSize);
              },
            )
          : Image.file(
              File(avatarPath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(student, fallbackFontSize);
              },
            ),
    );
  }

  Widget _buildAvatarFallback(Student student, double fallbackFontSize) {
    return Center(
      child: Text(
        student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fallbackFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
