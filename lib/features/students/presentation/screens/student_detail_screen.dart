import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/student.dart';

/// Dedicated page to show student details.
class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final statusTheme = _resolveStatusTheme(student.statusTitle);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Detail Siswa'),
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
                  emptyBackgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Center(
                child: Column(
                  children: [
                    Text(
                      student.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      '${student.schoolLevel} / ${student.className}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildStatusChip(
                      text: student.statusTitle,
                      backgroundColor: statusTheme.background,
                      borderColor: statusTheme.border,
                      textColor: statusTheme.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildStatusMessageBanner(
                title: student.statusTitle,
                description: student.statusDescription,
                icon: statusTheme.icon,
                backgroundColor: statusTheme.softBackground,
                borderColor: statusTheme.border.withValues(alpha: 0.35),
                iconColor: statusTheme.text,
                textColor: statusTheme.text,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildDetailRow(
                'Jenis Data',
                student.sourceType == 'candidate'
                    ? 'Calon Peserta Didik'
                    : 'Siswa Terdaftar',
              ),
              _buildDetailRow('Status', student.statusTitle),
              _buildDetailRow('Tahun Ajaran', student.academicYear),
              _buildDetailRow('Nama Lengkap', student.fullName),
              _buildDetailRow('Tingkat Sekolah', student.schoolLevel),
              _buildDetailRow('Kelas', student.className),
              _buildDetailRow('Sekolah', student.schoolName),
              _buildDetailRow('Alamat Sekolah', student.address),
              if (student.sourceType == 'candidate') ...[
                _buildDetailRow('ID Registrasi', student.registrationId),
                _buildDetailRow(
                  'Status Biaya Pendaftaran',
                  student.registrationFeeStatus,
                ),
                _buildDetailRow(
                  'Status Uang Pangkal',
                  student.buildingFeeStatus,
                ),
                _buildDetailRow('Informasi Tes', student.testInformation),
                _buildDetailRow(
                  'Kelengkapan Profil',
                  student.profileDataInformation,
                ),
              ] else ...[
                _buildDetailRow(
                  'Tanggal Lahir',
                  _formatDate(student.birthDate),
                ),
                _buildDetailRow('Wali Kelas', student.homeRoomTeacher),
                _buildDetailRow(
                  'Status Daftar Ulang',
                  student.reregisterOpenStatus,
                ),
              ],
              _buildDetailRow('Nomor Kartu Keluarga', student.familyCardNumber),
              _buildDetailRow('NIK', student.nik),
              _buildDetailRow('NISN', student.nisn),
              _buildDetailRow('Jenis Kelamin', student.gender),
              _buildDetailRow('Tempat Lahir', student.birthPlace),
              _buildDetailRow(
                'Nomor Telp Orang Tua',
                student.parentPhoneNumber,
              ),
              _buildDetailRow('Metode Pembayaran', student.paymentMethod),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String text,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusMessageBanner({
    required String title,
    required String description,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusTheme _resolveStatusTheme(String statusTitle) {
    final status = statusTitle.toLowerCase();

    if (status.contains('lulus')) {
      return const _StatusTheme(
        background: AppColors.successLight,
        softBackground: Color(0xFFE9F9EF),
        border: AppColors.success,
        text: AppColors.success,
        icon: Iconsax.tick_circle,
      );
    }

    if (status.contains('ditutup') ||
        status.contains('tidak lulus') ||
        status.contains('dikeluarkan') ||
        status.contains('mengundurkan') ||
        status.contains('dihentikan')) {
      return const _StatusTheme(
        background: AppColors.errorLight,
        softBackground: Color(0xFFFFF2F2),
        border: AppColors.error,
        text: AppColors.error,
        icon: Iconsax.warning_2,
      );
    }

    if (status.contains('menunggu') ||
        status.contains('proses') ||
        status.contains('lengkapi')) {
      return const _StatusTheme(
        background: Color(0xFFFFF6E8),
        softBackground: Color(0xFFFFF9EF),
        border: AppColors.warning,
        text: AppColors.warning,
        icon: Iconsax.clock,
      );
    }

    if (status.contains('mutasi')) {
      return const _StatusTheme(
        background: Color(0xFFE9F4FF),
        softBackground: Color(0xFFF2F8FF),
        border: AppColors.info,
        text: AppColors.info,
        icon: Iconsax.repeat,
      );
    }

    return const _StatusTheme(
      background: Color(0xFFEAF6FF),
      softBackground: Color(0xFFF2F9FF),
      border: AppColors.primary,
      text: AppColors.primary,
      icon: Iconsax.info_circle,
    );
  }

  Widget _buildStudentAvatar({
    required Student student,
    required double size,
    required double fallbackFontSize,
    bool isCircle = false,
    Color? emptyBackgroundColor,
  }) {
    final avatarPath = student.avatarUrl?.trim();
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;
    final isNetworkAvatar = hasAvatar && _isNetworkUrl(avatarPath);
    final fallbackBackgroundColor =
        emptyBackgroundColor ?? AppColors.primary.withValues(alpha: 0.1);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: emptyBackgroundColor == null && hasAvatar
            ? AppColors.primary.withValues(alpha: 0.1)
            : fallbackBackgroundColor,
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

class _StatusTheme {
  final Color background;
  final Color softBackground;
  final Color border;
  final Color text;
  final IconData icon;

  const _StatusTheme({
    required this.background,
    required this.softBackground,
    required this.border,
    required this.text,
    required this.icon,
  });
}
