import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
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
  StudentSortField _sortField = StudentSortField.name;
  bool _isSortAscending = true;

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

  void _updateSortField(StudentSortField field) {
    setState(() {
      _sortField = field;
    });
  }

  void _toggleSortDirection() {
    setState(() {
      _isSortAscending = !_isSortAscending;
    });
  }

  List<Student> _sortStudents(List<Student> students) {
    final sorted = List<Student>.from(students);

    int compareText(String a, String b) {
      return a.trim().toLowerCase().compareTo(b.trim().toLowerCase());
    }

    int compareStatus(String a, String b) {
      const order = <String, int>{
        'active': 0,
        'gratis': 1,
        'sudah diproses': 2,
        'belum diproses': 3,
        'menunggu': 4,
        'diumumkan': 5,
        'lulus': 6,
        'negosiasi': 7,
        'tidak lulus': 8,
      };
      final rankA = order[a.trim().toLowerCase()] ?? 99;
      final rankB = order[b.trim().toLowerCase()] ?? 99;
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return compareText(a, b);
    }

    sorted.sort((a, b) {
      final result = switch (_sortField) {
        StudentSortField.name => compareText(a.name, b.name),
        StudentSortField.birthDate => a.birthDate.compareTo(b.birthDate),
        StudentSortField.schoolName => compareText(a.schoolName, b.schoolName),
        StudentSortField.schoolLevel => compareText(
          a.schoolLevel,
          b.schoolLevel,
        ),
        StudentSortField.className => compareText(a.className, b.className),
        StudentSortField.status => compareStatus(a.status, b.status),
      };

      return _isSortAscending ? result : -result;
    });

    return sorted;
  }

  String _sortFieldLabel(StudentSortField field) {
    return switch (field) {
      StudentSortField.name => 'Nama',
      StudentSortField.birthDate => 'Tanggal lahir',
      StudentSortField.schoolName => 'Nama Sekolah',
      StudentSortField.schoolLevel => 'Tingkat Sekolah',
      StudentSortField.className => 'Kelas',
      StudentSortField.status => 'Status',
    };
  }

  bool get _isAlphabeticSortField {
    return _sortField == StudentSortField.name ||
        _sortField == StudentSortField.schoolName ||
        _sortField == StudentSortField.schoolLevel ||
        _sortField == StudentSortField.className;
  }

  String get _sortDirectionSuffix {
    if (!_isAlphabeticSortField) return '';
    return _isSortAscending ? ' (A-Z)' : ' (Z-A)';
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Student List'),
        actions: [
          PopupMenuButton<StudentSortField>(
            tooltip: 'Urutkan',
            onSelected: _updateSortField,
            itemBuilder: (context) {
              return StudentSortField.values.map((field) {
                final selected = field == _sortField;
                return PopupMenuItem<StudentSortField>(
                  value: field,
                  child: Row(
                    children: [
                      Icon(
                        selected ? Iconsax.tick_circle : Iconsax.sort,
                        size: 16,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(_sortFieldLabel(field)),
                    ],
                  ),
                );
              }).toList();
            },
            icon: const Icon(Iconsax.sort),
          ),
          IconButton(
            tooltip: _isSortAscending
                ? 'Ubah ke urutan menurun'
                : 'Ubah ke urutan menaik',
            onPressed: _toggleSortDirection,
            icon: Icon(
              _isSortAscending ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
            ),
          ),
        ],
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
              hint: 'Search by name',
              prefixIcon: Iconsax.search_normal,
              textInputAction: TextInputAction.done,
              onChanged: _filterStudents,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.paddingM,
              right: AppDimensions.paddingM,
              bottom: AppDimensions.paddingS,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingS,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.sort,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      'Sort: ${_sortFieldLabel(_sortField)}$_sortDirectionSuffix',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 450)),
          // Student List
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final filteredStudents = _searchQuery.isEmpty
                    ? students
                    : students
                          .where(
                            (student) => student.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                final sortedStudents = _sortStudents(filteredStudents);

                if (sortedStudents.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .read(studentsProvider.notifier)
                        .refreshStudents();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    itemCount: sortedStudents.length,
                    itemBuilder: (context, index) {
                      final student = sortedStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, _) => _buildErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.read(studentsProvider.notifier).refreshStudents();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      itemCount: 8,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.paddingS),
      itemBuilder: (_, _) {
        return Card(
          elevation: AppDimensions.elevationS,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: ShimmerListItem(),
          ),
        );
      },
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton(onPressed: onRetry, child: Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No students found',
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

  Widget _buildStudentCard(Student student) {
    final isActive = student.status == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.28),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.studentDetail, extra: student),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStudentAvatar(
                        student: student,
                        size: 56,
                        fallbackFontSize: 21,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        emptyBackgroundColor: Colors.white,
                        emptyBorderColor: AppColors.border,
                        emptyTextColor: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name.trim().isEmpty ? '-' : student.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              student.schoolLevel.trim().isEmpty
                                  ? 'Jenjang tidak tersedia'
                                  : student.schoolLevel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE8F0FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      _buildStatusBadge(
                        isActive: isActive,
                        status: student.status,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Divider(
                  height: 1,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _buildCardMetaRow(
                  icon: Iconsax.user,
                  label: 'Nama',
                  value: student.name,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.calendar_1,
                  label: 'Tanggal lahir',
                  value: _formatDate(student.birthDate),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.building_3,
                  label: 'Nama Sekolah',
                  value: student.schoolName,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.location,
                  label: 'Alamat Sekolah',
                  value: student.address,
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.book_1,
                  label: 'Kelas',
                  value: student.className,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required bool isActive, required String status}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.errorLight,
        border: Border.all(
          color: isActive ? AppColors.success : AppColors.error,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildCardMetaRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 1),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, size: 12, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: displayValue,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.28,
                  ),
                ),
              ],
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildStudentAvatar({
    required Student student,
    required double size,
    required double fallbackFontSize,
    BorderRadius? borderRadius,
    bool isCircle = false,
    Color? emptyBackgroundColor,
    Color? emptyBorderColor,
    Color? emptyTextColor,
  }) {
    final avatarPath = student.avatarUrl?.trim();
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;
    final isNetworkAvatar = hasAvatar && _isNetworkUrl(avatarPath);
    final fallbackBackgroundColor =
        emptyBackgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final fallbackBorderColor = emptyBorderColor;
    final fallbackTextColor = emptyTextColor ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: hasAvatar
            ? AppColors.primary.withValues(alpha: 0.1)
            : fallbackBackgroundColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppDimensions.radiusM)),
        border: !hasAvatar && fallbackBorderColor != null
            ? Border.all(color: fallbackBorderColor)
            : null,
      ),
      child: !hasAvatar
          ? _buildAvatarFallback(
              student,
              fallbackFontSize,
              textColor: fallbackTextColor,
            )
          : isNetworkAvatar
          ? Image.network(
              avatarPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(
                  student,
                  fallbackFontSize,
                  textColor: fallbackTextColor,
                );
              },
            )
          : avatarPath.startsWith('assets/')
          ? Image.asset(
              avatarPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(
                  student,
                  fallbackFontSize,
                  textColor: fallbackTextColor,
                );
              },
            )
          : Image.file(
              File(avatarPath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildAvatarFallback(
                  student,
                  fallbackFontSize,
                  textColor: fallbackTextColor,
                );
              },
            ),
    );
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.isScheme('http') || uri.isScheme('https');
  }

  Widget _buildAvatarFallback(
    Student student,
    double fallbackFontSize, {
    required Color textColor,
  }) {
    return Center(
      child: Text(
        student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fallbackFontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

enum StudentSortField {
  name,
  birthDate,
  schoolName,
  schoolLevel,
  className,
  status,
}




