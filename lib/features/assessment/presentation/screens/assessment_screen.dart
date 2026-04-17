import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/current_user_session_storage.dart';
import '../../../auth/domain/entities/user.dart';

class AssessmentStatusItem {
  final int status;
  final String statusName;
  final int? id;

  const AssessmentStatusItem({
    required this.status,
    required this.statusName,
    required this.id,
  });

  factory AssessmentStatusItem.fromJson(Map<String, dynamic> json) {
    return AssessmentStatusItem(
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusName: json['status_name']?.toString().trim() ?? '',
      id: int.tryParse(json['id']?.toString() ?? ''),
    );
  }
}

class AssessmentMonitoringItem {
  final int? id;
  final String submodulCode;
  final String subjectName;
  final String assessmentTypeName;
  final String assessmentMethod;
  final String assessmentDescription;
  final DateTime? assignDate;
  final DateTime? deadline;
  final String statusName;
  final String? score;

  const AssessmentMonitoringItem({
    required this.id,
    required this.submodulCode,
    required this.subjectName,
    required this.assessmentTypeName,
    required this.assessmentMethod,
    required this.assessmentDescription,
    required this.assignDate,
    required this.deadline,
    required this.statusName,
    required this.score,
  });

  factory AssessmentMonitoringItem.fromJson(Map<String, dynamic> json) {
    return AssessmentMonitoringItem(
      id: int.tryParse(json['id']?.toString() ?? ''),
      submodulCode: json['submodul_code']?.toString().trim() ?? '-',
      subjectName: json['subject_name']?.toString().trim() ?? '-',
      assessmentTypeName:
          json['assessment_type_name']?.toString().trim() ?? '-',
      assessmentMethod: json['online']?.toString().trim() ?? '-',
      assessmentDescription:
          json['assessment_desc']?.toString().trim().isNotEmpty == true
          ? json['assessment_desc'].toString().trim()
          : (json['assessment_detail']?.toString().trim() ?? '-'),
      assignDate: DateTime.tryParse(json['assign_date']?.toString() ?? ''),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      statusName: json['status_name']?.toString().trim() ?? '',
      score: json['score']?.toString(),
    );
  }
}

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  static const String _allFilterCode = 'ALL';
  static const List<String> _mainStatusNames = <String>[
    'Open',
    'On Review',
    'Done',
    'Missing',
  ];

  final ApiClient _apiClient = ApiClient();

  List<AssessmentStatusItem> _statusItems = _mainStatusNames
      .asMap()
      .entries
      .map(
        (entry) => AssessmentStatusItem(
          status: entry.key + 1,
          statusName: entry.value,
          id: null,
        ),
      )
      .toList();

  bool _isLoading = true;
  String? _errorMessage;
  int? _activeStudentId;
  List<String> _assessmentTypeCodes = <String>[_allFilterCode];
  String _selectedAssessmentTypeCode = _allFilterCode;
  final Map<int, Future<List<AssessmentMonitoringItem>>> _statusFutures =
      <int, Future<List<AssessmentMonitoringItem>>>{};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadAssessmentStatuses);
  }

  Future<void> _loadAssessmentStatuses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = ref.read(currentUserProvider);
      user ??= await readStoredCurrentUser();
      if (user != null && ref.read(currentUserProvider) == null) {
        ref.read(currentUserProvider.notifier).state = user;
      }

      final token = user?.userToken?.trim() ?? '';
      if (token.isNotEmpty) {
        _apiClient.setAuthToken(token);
      }

      final studentId = _resolveStudentId(user) ?? 670;
      _activeStudentId = studentId;

      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.assessmentStatus,
        data: <String, dynamic>{
          'search': <String, dynamic>{'nid_student': studentId},
        },
      );

      if (response.data is! Map<String, dynamic>) {
        throw StateError('Invalid assessment status response');
      }

      final payload = response.data as Map<String, dynamic>;
      final statusText = payload['status']?.toString();
      if (statusText != '1') {
        throw StateError(_extractPayloadMessage(payload));
      }

      final data = payload['data'];
      if (data is! List) {
        throw StateError('Assessment status data not found');
      }

      final parsed = data
          .map(_tryParseStatusItem)
          .whereType<AssessmentStatusItem>()
          .where((item) => item.statusName.isNotEmpty)
          .toList();

      if (parsed.isEmpty) {
        throw StateError('Assessment status data is empty');
      }

      final nextStatuses = _mapToMainStatuses(parsed);
      final typeCodes = await _loadAssessmentTypeCodes();

      if (!mounted) {
        return;
      }

      setState(() {
        _statusItems = nextStatuses;
        _assessmentTypeCodes = <String>[_allFilterCode, ...typeCodes];
        if (!_assessmentTypeCodes.contains(_selectedAssessmentTypeCode)) {
          _selectedAssessmentTypeCode = _allFilterCode;
        }
        _statusFutures
          ..clear()
          ..addEntries(
            nextStatuses.map(
              (item) => MapEntry(
                item.status,
                _loadMonitoringStatusItems(status: item.status),
              ),
            ),
          );
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _extractErrorMessage(error);
      });
    }
  }

  AssessmentStatusItem? _tryParseStatusItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      return AssessmentStatusItem.fromJson(item);
    }

    if (item is Map) {
      final converted = <String, dynamic>{};
      item.forEach((key, value) {
        converted[key.toString()] = value;
      });
      return AssessmentStatusItem.fromJson(converted);
    }

    return null;
  }

  AssessmentMonitoringItem? _tryParseMonitoringItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      return AssessmentMonitoringItem.fromJson(item);
    }

    if (item is Map) {
      final converted = <String, dynamic>{};
      item.forEach((key, value) {
        converted[key.toString()] = value;
      });
      return AssessmentMonitoringItem.fromJson(converted);
    }

    return null;
  }

  int? _resolveStudentId(User? user) {
    if (user == null) {
      return null;
    }

    final directStudentId = user.studentId;
    if (directStudentId != null && directStudentId > 0) {
      return directStudentId;
    }

    final children = user.childrenStudentId;
    if (children != null) {
      for (final id in children) {
        if (id > 0) {
          return id;
        }
      }
    }

    final id = int.tryParse(user.id);
    if (id != null && id > 0) {
      return id;
    }

    return null;
  }

  List<AssessmentStatusItem> _mapToMainStatuses(
    List<AssessmentStatusItem> rawStatuses,
  ) {
    final byName = <String, AssessmentStatusItem>{
      for (final item in rawStatuses)
        _normalizeStatusName(item.statusName): item,
    };

    return _mainStatusNames.asMap().entries.map((entry) {
      final statusName = entry.value;
      final fromApi = byName[_normalizeStatusName(statusName)];
      return fromApi ??
          AssessmentStatusItem(
            status: entry.key + 1,
            statusName: statusName,
            id: null,
          );
    }).toList();
  }

  Future<List<AssessmentMonitoringItem>> _loadMonitoringStatusItems({
    required int status,
  }) async {
    final studentId = _activeStudentId ?? 670;

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.assessmentMonitoringStatus,
      data: <String, dynamic>{
        'search': <String, dynamic>{'nid_student': studentId, 'status': status},
      },
    );

    if (response.data is! Map<String, dynamic>) {
      throw StateError('Invalid monitoring status response');
    }

    final payload = response.data as Map<String, dynamic>;
    if (payload['status']?.toString() != '1') {
      throw StateError(_extractPayloadMessage(payload));
    }

    final data = payload['data'];
    if (data is! List) {
      return <AssessmentMonitoringItem>[];
    }

    return data
        .map(_tryParseMonitoringItem)
        .whereType<AssessmentMonitoringItem>()
        .toList();
  }

  Future<List<String>> _loadAssessmentTypeCodes() async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.assessmentType,
        data: const <String, dynamic>{'search': <String, dynamic>{}},
      );

      if (response.data is! Map<String, dynamic>) {
        return <String>[];
      }

      final payload = response.data as Map<String, dynamic>;
      if (payload['status']?.toString() != '1') {
        return <String>[];
      }

      final data = payload['data'];
      if (data is! List) {
        return <String>[];
      }

      final seen = <String>{};
      final codes = <String>[];

      for (final item in data) {
        if (item is! Map) {
          continue;
        }
        final code = item['setting_code']?.toString().trim() ?? '';
        if (code.isEmpty) {
          continue;
        }
        final normalized = code.toUpperCase();
        if (seen.add(normalized)) {
          codes.add(normalized);
        }
      }

      return codes;
    } catch (_) {
      return <String>[];
    }
  }

  List<AssessmentMonitoringItem> _applyTypeFilter(
    List<AssessmentMonitoringItem> items,
  ) {
    if (_selectedAssessmentTypeCode == _allFilterCode) {
      return items;
    }

    return items.where((item) {
      return item.assessmentTypeName.trim().toUpperCase() ==
          _selectedAssessmentTypeCode;
    }).toList();
  }

  Future<void> _reloadSingleStatus(int status) async {
    setState(() {
      _statusFutures[status] = _loadMonitoringStatusItems(status: status);
    });

    await _statusFutures[status];
  }

  String _normalizeStatusName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _extractPayloadMessage(Map<String, dynamic> payload) {
    final message = payload['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    if (message is Map<String, dynamic>) {
      final error = message['errmsg']?.toString().trim();
      final msg = message['msg']?.toString().trim();
      final detail = message['message']?.toString().trim();
      if (error != null && error.isNotEmpty) {
        return error;
      }
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
    }

    return 'Failed to load assessment data';
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map<String, dynamic>) {
        return _extractPayloadMessage(payload);
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please try again';
      }

      return error.message ?? 'Request failed';
    }

    return error.toString();
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) {
      return '-';
    }

    final local = deadline.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  IconData _iconForStatus(String statusName) {
    final normalized = _normalizeStatusName(statusName);
    if (normalized == 'open') {
      return Iconsax.folder_open;
    }
    if (normalized == 'on review') {
      return Iconsax.search_status;
    }
    if (normalized == 'done') {
      return Iconsax.tick_circle;
    }
    return Iconsax.warning_2;
  }

  Color _colorForStatus(String statusName) {
    final normalized = _normalizeStatusName(statusName);
    if (normalized == 'open') {
      return AppColors.info;
    }
    if (normalized == 'on review') {
      return AppColors.warning;
    }
    if (normalized == 'done') {
      return AppColors.success;
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _statusItems.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Assessment'),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Iconsax.refresh),
              onPressed: _isLoading ? null : _loadAssessmentStatuses,
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            tabs: _statusItems
                .map(
                  (item) => Tab(
                    child: Tooltip(
                      message: item.statusName,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          item.statusName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        body: _isLoading
            ? _buildMonitoringLoadingSkeleton()
            : _errorMessage != null
            ? _buildErrorState()
            : TabBarView(
                children: _statusItems
                    .map((item) => _buildStatusContent(item))
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 40, color: AppColors.error),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              _errorMessage ?? 'Failed to load data',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton.icon(
              onPressed: _loadAssessmentStatuses,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(AssessmentStatusItem item) {
    final statusColor = _colorForStatus(item.statusName);
    final statusFuture =
        _statusFutures[item.status] ??
        _loadMonitoringStatusItems(status: item.status);

    return FutureBuilder<List<AssessmentMonitoringItem>>(
      future: statusFuture,
      builder: (context, snapshot) {
        final allItems = snapshot.data ?? <AssessmentMonitoringItem>[];
        final filteredItems = _applyTypeFilter(allItems);

        return RefreshIndicator(
          onRefresh: () => _reloadSingleStatus(item.status),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            children: [
              Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: Icon(
                            _iconForStatus(item.statusName),
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.statusName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              Text(
                                '${filteredItems.length} item',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.textOnPrimary.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .slideY(begin: -0.12, end: 0),
              const SizedBox(height: AppDimensions.paddingM),
              _buildFilterChips(),
              const SizedBox(height: AppDimensions.paddingM),
              if (snapshot.connectionState == ConnectionState.waiting)
                _buildMonitoringLoadingSkeleton(itemCount: 4)
              else if (snapshot.hasError)
                _buildTabErrorCard(item.status, snapshot.error)
              else
                ..._buildMonitoringCards(
                  filteredItems,
                  fallbackStatusName: item.statusName,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Assessment Type',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _assessmentTypeCodes.map((code) {
                final isSelected = code == _selectedAssessmentTypeCode;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingS),
                  child: ChoiceChip(
                    label: Text(code == _allFilterCode ? 'ALL' : code),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedAssessmentTypeCode = code;
                      });
                    },
                    showCheckmark: false,
                    selectedColor: AppColors.primary.withValues(alpha: 0.18),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringLoadingSkeleton({int itemCount = 5}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.surface,
          child: Card(
            elevation: AppDimensions.elevationS,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonLine(width: 120),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: double.infinity),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: 150),
                  const SizedBox(height: AppDimensions.paddingS),
                  _buildSkeletonLine(width: 180),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLine({required double width}) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
    );
  }

  Widget _buildTabErrorCard(int status, Object? error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Failed to load assessment data',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              error == null ? '-' : _extractErrorMessage(error),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton.icon(
              onPressed: () => _reloadSingleStatus(status),
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonitoringCards(
    List<AssessmentMonitoringItem> items, {
    required String fallbackStatusName,
  }) {
    if (items.isEmpty) {
      return <Widget>[
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(
                Iconsax.document,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                size: 26,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'No assessment data',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return items.map((item) {
      return InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            onTap: () => _showAssessmentDetail(
              item,
              fallbackStatusName: fallbackStatusName,
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              elevation: AppDimensions.elevationS,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                side: BorderSide(
                  color: AppColors.borderLight.withValues(alpha: 0.8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.submodulCode,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS,
                            ),
                          ),
                          child: Text(
                            item.assessmentTypeName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        item.subjectName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.calendar,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.paddingXS),
                        Text(
                          'Deadline: ${_formatDeadline(item.deadline)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.score?.trim().isNotEmpty == true
                              ? 'Score: ${item.score!.trim()}'
                              : 'Score: -',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 140))
          .slideY(begin: 0.06, end: 0);
    }).toList();
  }

  void _showAssessmentDetail(
    AssessmentMonitoringItem item, {
    required String fallbackStatusName,
  }) {
    final statusText = item.statusName.trim().isEmpty
        ? fallbackStatusName
        : item.statusName;
    final statusColor = _colorForStatus(statusText);

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingXL,
          ),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    AppDimensions.paddingL,
                    AppDimensions.paddingM,
                    AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assessment Detail',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS,
                                vertical: AppDimensions.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.58,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetaRow(
                            label: 'Assessment Type',
                            value: item.assessmentTypeName,
                          ),
                          _buildMetaRow(
                            label: 'Subject',
                            value: item.subjectName,
                          ),
                          _buildMetaRow(
                            label: 'Assessment Method',
                            value: item.assessmentMethod.trim().isEmpty
                                ? '-'
                                : item.assessmentMethod,
                          ),
                          _buildMetaRow(
                            label: 'Assessment Description',
                            value: item.assessmentDescription.trim().isEmpty
                                ? '-'
                                : item.assessmentDescription,
                          ),
                          _buildMetaRow(
                            label: 'Assign Date',
                            value: _formatDeadline(item.assignDate),
                          ),
                          _buildMetaRow(
                            label: 'Deadline Date',
                            value: _formatDeadline(item.deadline),
                          ),
                          _buildMetaRow(label: 'Status', value: statusText),
                          _buildMetaRow(
                            label: 'Score',
                            value: item.score?.trim().isNotEmpty == true
                                ? item.score!.trim()
                                : '-',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    0,
                    AppDimensions.paddingL,
                    AppDimensions.paddingL,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
