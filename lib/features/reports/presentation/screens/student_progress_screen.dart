import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/current_user_session_storage.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/models/student_progress_graph_score_item.dart';
import '../../data/repositories/student_progress_repository.dart';

/// Student Progress screen backed by graph-score API.
class StudentProgressScreen extends ConsumerStatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  ConsumerState<StudentProgressScreen> createState() =>
      _StudentProgressScreenState();
}

class _StudentProgressScreenState extends ConsumerState<StudentProgressScreen> {
  final StudentProgressRepository _repository = StudentProgressRepository();

  late Future<List<StudentProgressGraphScoreItem>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
  }

  String _normalizeLoginType(String rawRole) {
    final role = rawRole.trim().toLowerCase();
    if (role.contains('parent')) {
      return 'parent';
    }
    if (role.contains('student')) {
      return 'student';
    }
    return role;
  }

  int? _resolveStudentId(User user) {
    if ((user.studentId ?? 0) > 0) {
      return user.studentId;
    }

    final children = user.childrenStudentId;
    if (children != null) {
      for (final id in children) {
        if (id > 0) {
          return id;
        }
      }
    }

    final parsed = int.tryParse(user.id);
    if ((parsed ?? 0) > 0) {
      return parsed;
    }

    return null;
  }

  Future<List<StudentProgressGraphScoreItem>> _loadProgress() async {
    User? user = ref.read(currentUserProvider);
    user ??= await readStoredCurrentUser();

    if (user == null) {
      throw const StudentProgressException('User session not found.');
    }

    if (ref.read(currentUserProvider) == null) {
      ref.read(currentUserProvider.notifier).state = user;
    }

    final authToken = user.userToken?.trim() ?? '';
    final normalizedLoginType = _normalizeLoginType(user.role);
    final studentId = _resolveStudentId(user);

    final loginType = (studentId ?? 0) > 0 ? 'student' : normalizedLoginType;

    final parsedUserId = int.tryParse(user.id);
    final requestId = (parsedUserId ?? 0) > 0
        ? parsedUserId.toString()
        : (studentId?.toString() ?? '');

    if (authToken.isEmpty || requestId.isEmpty || (studentId ?? 0) <= 0) {
      throw const StudentProgressException('User session is incomplete.');
    }

    return _repository.getGraphScores(
      id: requestId,
      loginType: loginType,
      student: studentId.toString(),
      authToken: authToken,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _progressFuture = _loadProgress();
    });
    await _progressFuture;
  }

  Color _gradeColor(double grade) {
    if (grade >= 85) {
      return AppColors.success;
    }
    if (grade >= 70) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Student Progress'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Iconsax.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<StudentProgressGraphScoreItem>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final allItems = snapshot.data ?? <StudentProgressGraphScoreItem>[];
          if (allItems.isEmpty) {
            return _buildEmptyState();
          }

          final summaryItems = allItems;
          final subjectScoreItems = [...allItems]
            ..sort((a, b) => b.finalGrade.compareTo(a.finalGrade));

          final averageScore =
              summaryItems.map((e) => e.finalGrade).reduce((a, b) => a + b) /
              summaryItems.length;
          final best = summaryItems.reduce(
            (value, element) =>
                value.finalGrade >= element.finalGrade ? value : element,
          );

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(
                    averageScore: averageScore,
                    totalSubjects: summaryItems.length,
                    bestSubject: best.subjectName,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _buildGraphScoreCard(summaryItems),
                  const SizedBox(height: AppDimensions.paddingM),
                  const Text(
                    'Subject Scores',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    'Total data: ${subjectScoreItems.length}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  ...subjectScoreItems.asMap().entries.map((entry) {
                    return _buildSubjectCard(entry.value, entry.key);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required double averageScore,
    required int totalSubjects,
    required String bestSubject,
  }) {
    return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: (averageScore / 100).clamp(0, 1),
                        strokeWidth: 8,
                        backgroundColor: AppColors.surface.withValues(
                          alpha: 0.28,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          averageScore.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Pencapaian',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      'Mata pelajaran: $totalSubjects',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Terbaik: $bestSubject',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 380))
        .slideY(begin: -0.08, end: 0);
  }

  Widget _buildGraphScoreCard(List<StudentProgressGraphScoreItem> items) {
    final graphItems = [...items]
      ..sort((a, b) => b.finalGrade.compareTo(a.finalGrade));
    final visibleItems = graphItems.take(6).toList();
    final maxScore = visibleItems.isEmpty
        ? 100.0
        : visibleItems
              .map((e) => e.finalGrade)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, 100)
              .toDouble();

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.chart_21, size: 18, color: AppColors.info),
                  SizedBox(width: AppDimensions.paddingS),
                  Text(
                    'Graph Score',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'Top ${visibleItems.length} mata pelajaran',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              ...visibleItems.asMap().entries.map((entry) {
                return _buildSimpleGraphRow(
                  item: entry.value,
                  index: entry.key,
                  maxScore: maxScore,
                  isLast: entry.key == visibleItems.length - 1,
                );
              }),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 120),
          duration: const Duration(milliseconds: 320),
        )
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildSimpleGraphRow({
    required StudentProgressGraphScoreItem item,
    required int index,
    required double maxScore,
    required bool isLast,
  }) {
    final normalized = (item.finalGrade / maxScore).clamp(0.0, 1.0);
    final color = _gradeColor(item.finalGrade);
    final safeName = item.subjectName.trim().isEmpty ? '-' : item.subjectName;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.paddingM),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 60)),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: normalized),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: AppColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          SizedBox(
            width: 36,
            child: Text(
              item.finalGrade.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(StudentProgressGraphScoreItem item, int index) {
    final normalized = (item.finalGrade / 100).clamp(0.0, 1.0);
    final color = _gradeColor(item.finalGrade);
    final safeName = item.subjectName.trim().isEmpty ? '-' : item.subjectName;

    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        safeName[0].toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        safeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        item.finalGrade.toStringAsFixed(0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: normalized,
                          minHeight: 8,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      '${(normalized * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 140 + (index * 45)),
          duration: const Duration(milliseconds: 280),
        )
        .slideX(begin: 0.06, end: 0);
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.chart_21,
              size: 44,
              color: AppColors.textSecondary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Data progress belum tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 40, color: AppColors.warning),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
