import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/student.dart';

/// Dedicated page to show student details.
class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: AppColors.borderLight),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _buildStudentAvatar(
                  student: student,
                  size: 96,
                  fallbackFontSize: 36,
                  isCircle: true,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Center(
                child: Text(
                  student.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildDetailRow('Tahun Ajaran', student.academicYear),
              _buildDetailRow('Nomor Kartu Keluarga', student.familyCardNumber),
              _buildDetailRow('NIK', student.nik),
              _buildDetailRow('Nama Lengkap', student.fullName),
              _buildDetailRow('Tanggal Lahir', _formatDate(student.birthDate)),
              _buildDetailRow('Jenis Kelamin', student.gender),
              _buildDetailRow('Tingkat Sekolah', student.schoolLevel),
              _buildDetailRow('Kelas', student.className),
              _buildDetailRow('Sekolah', student.schoolName),
              _buildDetailRow('Alamat Sekolah', student.address),
              _buildDetailRow(
                'Nomor Telp Orang Tua',
                student.parentPhoneNumber,
              ),
              _buildDetailRow('Metode Pembayaran', student.paymentMethod),
              _buildDetailRow('Status', student.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAvatar({
    required Student student,
    required double size,
    required double fallbackFontSize,
    bool isCircle = false,
  }) {
    final avatarPath = student.avatarUrl?.trim();
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;
    final isNetworkAvatar = hasAvatar && _isNetworkUrl(avatarPath);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: !hasAvatar
          ? _buildAvatarFallback(student, fallbackFontSize)
          : isNetworkAvatar
          ? Image.network(
              avatarPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(student, fallbackFontSize);
              },
            )
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

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.isScheme('http') || uri.isScheme('https');
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
    final displayValue = value.trim().isEmpty ? '-' : value;

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
              displayValue,
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
