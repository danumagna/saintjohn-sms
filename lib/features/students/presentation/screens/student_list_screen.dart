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
  StudentSourceFilter _sourceFilter = StudentSourceFilter.all;

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

  void _updateSourceFilter(StudentSourceFilter filter) {
    setState(() {
      _sourceFilter = filter;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterStudents('');
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _sourceFilter = StudentSourceFilter.all;
      _sortField = StudentSortField.name;
      _isSortAscending = true;
    });
  }

  List<Student> _sortStudents(List<Student> students) {
    final sorted = List<Student>.from(students);

    int compareText(String a, String b) {
      return a.trim().toLowerCase().compareTo(b.trim().toLowerCase());
    }

    int compareStatus(String a, String b) {
      const order = <String, int>{
        'siswa aktif': 0,
        'daftar ulang berhasil': 1,
        'menunggu pengumuman wali kelas': 2,
        'informasi wali kelas menunggu': 3,
        'menunggu tes evaluasi': 4,
        'dalam proses administrasi': 5,
        'lengkapi profil dan pembayaran': 6,
        'daftar ulang ditutup': 7,
        'lulus': 8,
        'mutasi siswa': 9,
        'tidak lulus atau tinggal kelas': 10,
        'mengundurkan diri': 11,
        'dikeluarkan': 12,
        'proses administrasi dihentikan': 13,
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

  bool get _hasActiveFilter {
    return _searchQuery.isNotEmpty ||
        _sourceFilter != StudentSourceFilter.all ||
        _sortField != StudentSortField.name ||
        !_isSortAscending;
  }

  bool _matchesSourceFilter(Student student) {
    switch (_sourceFilter) {
      case StudentSourceFilter.all:
        return true;
      case StudentSourceFilter.candidate:
        return student.sourceType == 'candidate';
      case StudentSourceFilter.student:
        return student.sourceType != 'candidate';
    }
  }

  String _sourceFilterLabel(StudentSourceFilter filter) {
    return switch (filter) {
      StudentSourceFilter.all => 'Semua',
      StudentSourceFilter.candidate => 'Calon Peserta Didik',
      StudentSourceFilter.student => 'Siswa Terdaftar',
    };
  }

  int _countBySource(List<Student> students, StudentSourceFilter filter) {
    if (filter == StudentSourceFilter.all) {
      return students.length;
    }
    return students.where((student) {
      if (filter == StudentSourceFilter.candidate) {
        return student.sourceType == 'candidate';
      }
      return student.sourceType != 'candidate';
    }).length;
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: _clearSearch,
                      icon: const Icon(Iconsax.close_circle),
                    )
                  : null,
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
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: StudentSourceFilter.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppDimensions.paddingS),
                itemBuilder: (context, index) {
                  final filter = StudentSourceFilter.values[index];
                  final selected = filter == _sourceFilter;
                  return ChoiceChip(
                    label: Text(_sourceFilterLabel(filter)),
                    selected: selected,
                    onSelected: (_) => _updateSourceFilter(filter),
                    showCheckmark: false,
                    selectedColor: AppColors.primary.withValues(alpha: 0.14),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.borderLight,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.paddingM,
              right: AppDimensions.paddingM,
              bottom: AppDimensions.paddingS,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
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
                ),
                if (_hasActiveFilter)
                  TextButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Iconsax.refresh, size: 16),
                    label: const Text('Clear Filter'),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 560)),
          // Student List
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final searchFilteredStudents = _searchQuery.isEmpty
                    ? students
                    : students
                          .where(
                            (student) => student.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                final filteredStudents = searchFilteredStudents
                    .where(_matchesSourceFilter)
                    .toList();
                final sortedStudents = _sortStudents(filteredStudents);

                if (sortedStudents.isEmpty) {
                  return _buildEmptyState(
                    hasSearch: _searchQuery.isNotEmpty,
                    hasSourceFilter: _sourceFilter != StudentSourceFilter.all,
                  );
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
                    itemCount: sortedStudents.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSummarySection(
                          allCount: _countBySource(
                            students,
                            StudentSourceFilter.all,
                          ),
                          candidateCount: _countBySource(
                            students,
                            StudentSourceFilter.candidate,
                          ),
                          studentCount: _countBySource(
                            students,
                            StudentSourceFilter.student,
                          ),
                          visibleCount: sortedStudents.length,
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 320),
                        );
                      }

                      final itemIndex = index - 1;
                      final student = sortedStudents[itemIndex];
                      return _buildStudentCard(student)
                          .animate(
                            delay: Duration(milliseconds: itemIndex * 45),
                          )
                          .fadeIn(duration: const Duration(milliseconds: 260))
                          .slideY(begin: 0.04, end: 0);
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

  Widget _buildEmptyState({
    required bool hasSearch,
    required bool hasSourceFilter,
  }) {
    final message = hasSearch || hasSourceFilter
        ? 'Tidak ada data yang sesuai dengan pencarian atau filter.'
        : 'Belum ada data siswa yang tersedia.';

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
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          if (hasSearch || hasSourceFilter) ...[
            const SizedBox(height: AppDimensions.paddingM),
            OutlinedButton.icon(
              onPressed: () {
                _clearAllFilters();
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('Reset Filter'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required int allCount,
    required int candidateCount,
    required int studentCount,
    required int visibleCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Data Siswa',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryChip(
                  label: 'Total',
                  value: allCount,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                _buildSummaryChip(
                  label: 'Calon',
                  value: candidateCount,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                _buildSummaryChip(
                  label: 'Siswa',
                  value: studentCount,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                _buildSummaryChip(
                  label: 'Ditampilkan',
                  value: visibleCount,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXS,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    final statusTheme = _resolveStatusTheme(student.statusTitle);

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
                            const SizedBox(height: AppDimensions.paddingS),
                            _buildStatusBadge(
                              status: student.statusTitle,
                              backgroundColor: statusTheme.background,
                              borderColor: statusTheme.border,
                              textColor: statusTheme.text,
                            ),
                          ],
                        ),
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
                const SizedBox(height: AppDimensions.paddingM),
                Divider(
                  height: 1,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _buildCardMetaRow(
                  icon: Iconsax.category,
                  label: 'Jenis Data',
                  value: student.sourceType == 'candidate'
                      ? 'Calon Peserta Didik'
                      : 'Siswa Terdaftar',
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.user,
                  label: 'Nama',
                  value: student.name,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.building_3,
                  label: 'Nama Sekolah',
                  value: student.schoolName,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.calendar_1,
                  label: 'Tahun Ajaran',
                  value: student.academicYear,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                _buildCardMetaRow(
                  icon: Iconsax.book_1,
                  label: 'Jenjang / Kelas',
                  value: '${student.schoolLevel} / ${student.className}',
                ),
                ..._buildSourceSpecificRows(student),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required String status,
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
        status,
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

  List<Widget> _buildSourceSpecificRows(Student student) {
    if (student.sourceType == 'candidate') {
      return <Widget>[
        const SizedBox(height: AppDimensions.paddingS),
        _buildCardMetaRow(
          icon: Iconsax.document_text,
          label: 'ID Registrasi',
          value: student.registrationId,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        _buildCardMetaRow(
          icon: Iconsax.card_edit,
          label: 'Status Biaya Pendaftaran',
          value: student.registrationFeeStatus,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        _buildCardMetaRow(
          icon: Iconsax.money_change,
          label: 'Status Uang Pangkal',
          value: student.buildingFeeStatus,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        _buildCardMetaRow(
          icon: Iconsax.clipboard_tick,
          label: 'Informasi Tes',
          value: student.testInformation,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        _buildCardMetaRow(
          icon: Iconsax.profile_tick,
          label: 'Kelengkapan Profil',
          value: student.profileDataInformation,
        ),
      ];
    }

    return <Widget>[
      const SizedBox(height: AppDimensions.paddingS),
      _buildCardMetaRow(
        icon: Iconsax.calendar_1,
        label: 'Tanggal Lahir',
        value: _formatDate(student.birthDate),
      ),
      const SizedBox(height: AppDimensions.paddingS),
      _buildCardMetaRow(
        icon: Iconsax.teacher,
        label: 'Wali Kelas',
        value: student.homeRoomTeacher,
      ),
      const SizedBox(height: AppDimensions.paddingS),
      _buildCardMetaRow(
        icon: Iconsax.activity,
        label: 'Status Daftar Ulang',
        value: student.reregisterOpenStatus,
      ),
      const SizedBox(height: AppDimensions.paddingS),
      _buildCardMetaRow(
        icon: Iconsax.location,
        label: 'Alamat Sekolah',
        value: student.address,
        maxLines: 2,
      ),
    ];
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
        color: emptyBackgroundColor == null && hasAvatar
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

enum StudentSourceFilter { all, candidate, student }

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
