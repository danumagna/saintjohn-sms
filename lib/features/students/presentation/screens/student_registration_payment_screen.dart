import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../domain/entities/registration_payment_args.dart';
import '../../providers/students_provider.dart';

class StudentRegistrationPaymentScreen extends ConsumerStatefulWidget {
  final RegistrationPaymentArgs args;

  const StudentRegistrationPaymentScreen({required this.args, super.key});

  @override
  ConsumerState<StudentRegistrationPaymentScreen> createState() =>
      _StudentRegistrationPaymentScreenState();
}

class _StudentRegistrationPaymentScreenState
    extends ConsumerState<StudentRegistrationPaymentScreen> {
  late Future<double> _priceFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceFuture = _fetchPrice();
  }

  Future<double> _fetchPrice() {
    final user = ref.read(currentUserProvider);
    final userToken = user?.userToken?.trim() ?? '';

    return ref
        .read(studentsRepositoryProvider)
        .getRegistrationPrice(
          authToken: userToken,
          payload: widget.args.registrationPricePayload,
        );
  }

  String _formatCurrency(double value) {
    final valueText = value.toStringAsFixed(0);
    final withSeparator = valueText.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]}.',
    );
    return 'Rp $withSeparator';
  }

  Future<void> _submitRegistration(double registrationPrice) async {
    if (_isSubmitting) return;

    final user = ref.read(currentUserProvider);
    final userToken = user?.userToken?.trim() ?? '';
    final payload =
        Map<String, dynamic>.from(widget.args.registrationPricePayload)
          ..['fullName'] = widget.args.fullName
          ..['studentFeePayment'] = registrationPrice;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(studentsRepositoryProvider)
          .submitStudentRegistration(authToken: userToken, payload: payload);

      if (!mounted) return;

      ref.invalidate(studentsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran siswa berhasil dikirim.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go(AppRoutes.parentDashboard);
    } on Exception catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage.isEmpty
                ? 'Gagal mengirim pendaftaran siswa.'
                : errorMessage,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim pendaftaran siswa.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pembayaran'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: FutureBuilder<double>(
            future: _priceFuture,
            builder: (context, snapshot) {
              final canContinue =
                  snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError &&
                  !_isSubmitting;

              return Column(
                children: [
                  Expanded(child: _buildContent(snapshot)),
                  const SizedBox(height: AppDimensions.paddingM),
                  PrimaryButton(
                    text: 'Selesai',
                    icon: Iconsax.wallet,
                    isLoading: _isSubmitting,
                    isDisabled: !canContinue,
                    onPressed: canContinue
                        ? () => _submitRegistration(snapshot.data ?? 0)
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<double> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingSkeleton();
    }

    if (snapshot.hasError) {
      return SingleChildScrollView(
        child: _buildErrorState(snapshot.error.toString()),
      );
    }

    final registrationPrice = snapshot.data ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: AppDimensions.paddingM),
          _buildInfoCard(
            title: 'Data Pendaftaran',
            child: Column(
              children: [
                _buildRow(
                  icon: Iconsax.user,
                  label: 'Nama Lengkap (Berdasarkan Akta)',
                  value: widget.args.fullName,
                ),
                _buildDivider(),
                _buildRow(
                  icon: Iconsax.buildings,
                  label: 'Tingkat Sekolah',
                  value: widget.args.schoolLevel,
                ),
                _buildDivider(),
                _buildRow(
                  icon: Iconsax.teacher,
                  label: 'Kelas',
                  value: widget.args.className,
                ),
                _buildDivider(),
                _buildRow(
                  icon: Iconsax.building,
                  label: 'Sekolah',
                  value: widget.args.schoolName,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildInfoCard(
            title: 'Ringkasan Biaya',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biaya Formulir Pendaftaran',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    _formatCurrency(registrationPrice),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.paddingXS),
          Text(
            'Periksa kembali data sebelum melanjutkan proses pembayaran.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          child,
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: AppDimensions.paddingM,
      color: AppColors.borderLight,
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.warning_2, color: AppColors.error, size: 18),
              SizedBox(width: AppDimensions.paddingS),
              Text(
                'Gagal Memuat Biaya',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: () {
              setState(() {
                _priceFuture = _fetchPrice();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        ],
      ),
    );
  }
}
