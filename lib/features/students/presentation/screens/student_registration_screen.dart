import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/student.dart';
import '../../providers/students_provider.dart';

/// Student registration screen for adding new students.
class StudentRegistrationScreen extends ConsumerStatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  ConsumerState<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends ConsumerState<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final _familyCardNumberController = TextEditingController();
  final _nikController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  int _currentStep = 0;
  bool _agreeInfoStepOne = false;
  bool _agreeInfoStepTwo = false;
  bool _isLoading = false;
  XFile? _selectedPhoto;

  DateTime? _selectedBirthDate;

  String _selectedAcademicYear = '';
  String _selectedGender = 'Pria';
  String _selectedSchoolLevel = 'KB / Playgroup';
  String _selectedClass = '';
  String _selectedSchool = '';
  String _selectedPaymentMethod = 'Virtual Account';

  final List<String> _genderOptions = ['Pria', 'Wanita'];
  final List<String> _schoolLevelOptions = [
    'KB / Playgroup',
    'TK',
    'SD',
    'SMP',
    'SMA',
  ];
  final List<String> _paymentMethodOptions = ['Virtual Account', 'Transfer'];

  final Map<String, List<String>> _classOptionsByLevel = const {
    'KB': ['Kelompok Bermain'],
    'TK': ['TK A', 'TK B'],
    'SD': ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4', 'Kelas 5', 'Kelas 6'],
    'SMP': ['Kelas 7', 'Kelas 8', 'Kelas 9'],
    'SMA': ['Kelas 10', 'Kelas 11', 'Kelas 12'],
  };

  final Map<String, List<String>> _schoolOptionsByLevel = const {
    'KB': ['KB SAINT JOHN BUNGUR', 'KB SAINT JOHN HARAPAN INDAH'],
    'TK': ['TK SAINT JOHN BUNGUR', 'TK SAINT JOHN HARAPAN INDAH'],
    'SD': ['SD SAINT JOHN BUNGUR', 'SD SAINT JOHN HARAPAN INDAH'],
    'SMP': ['SMP SAINT JOHN BUNGUR', 'SMP SAINT JOHN HARAPAN INDAH'],
    'SMA': ['SMA SAINT JOHN BUNGUR', 'SMA SAINT JOHN HARAPAN INDAH'],
  };

  List<String> get _academicYearOptions {
    final year = DateTime.now().year;
    return ['$year/${year + 1}', '${year + 1}/${year + 2}'];
  }

  String get _schoolLevelKey {
    if (_selectedSchoolLevel.startsWith('KB')) {
      return 'KB';
    }
    return _selectedSchoolLevel;
  }

  List<String> get _classOptions {
    return _classOptionsByLevel[_schoolLevelKey] ?? const [];
  }

  List<String> get _schoolOptions {
    return _schoolOptionsByLevel[_schoolLevelKey] ?? const [];
  }

  static const String _infoStepTwoContent = '''
Pada saat anak kami diterima dan melanjutkan di Sekolah Kristen Saint John, bersama ini kami menyatakan bahwa :

I. PERATURAN
1.1 Anak kami akan menaati setiap peraturan dan tata tertib sekolah tanpa pengecualian dan bersedia menerima setiap sanksi yang tertulis dalam Tata Tertib Sekolah apabila ia tidak menaatinya.
1.2 Kami memberikan ijin kepada anak kami tersebut untuk mengikuti semua program pendidikan dan kegiatan yang diselenggarakan oleh Sekolah Kristen Saint John, termasuk di dalamnya pendidikan Agama Kristen dan pembinaan spiritual dan karakter sesuai dengan ajaran Gereja Kristen Indonesia (GKI) dengan mengikuti seluruh kegiatan kerohanian dan karakter yang ada.
1.3 Kami memberikan ijin kepada pihak Sekolah Kristen Saint John untuk sewaktu-waktu, tanpa pemberitahuan terlebih dahulu kepada kami, melakukan screening test (tes urine/pemeriksaan laboratorium) terhadap penyalahgunaan Narkotika, Alkohol, Psikotropika, Zat Adiktif (NAPZA) dan penggunaan rokok serta melakukan penggeledahan dan/atau bentuk razia lain terhadap diri anak kami tersebut maupun barang yang dibawanya. Jika ternyata hasil tes tersebut positif, maka kami bersedia menanggung biaya tes urin/pemeriksaan laboratorium yang dilakukan oleh pihak Sekolah Kristen Saint John terhadap anak kami tersebut.
1.4 Kami menyetujui anak kami diberi sanksi sesuai dengan ketentuan yang berlaku, apabila anak kami terlibat dalam penyalahgunaan maupun peredaran NAPZA dan penggunaan rokok.
1.5 Kami menyetujui dan menerima anak kami dikembalikan kepada kami oleh pihak sekolah, bila pada waktu berjalan ditemukan bahwa anak kami melakukan perilaku menyimpang dan atau berkebutuhan khusus yang tidak dapat mengikuti pembelajaran secara normal.
1.6 Jika di kemudian hari didapatkan bahwa dokumen-dokumen dan/atau data/informasi yang kami berikan tidak sah dan/atau tidak benar, maka kami menyetujui pembatalan penerimaan anak kami tersebut sebagai siswa oleh pihak Sekolah Kristen Saint John secara sepihak atau anak kami dikeluarkan apabila sudah terlanjur bersekolah di Sekolah Kristen Saint John, dan kami tidak akan menuntut dengan alasan apapun.
1.7 Apabila ternyata kami tidak memenuhi ketentuan di atas, maka kami bersedia untuk anak kami dikembalikan kepada orang tua / dinyatakan keluar dari Sekolah Kristen Saint John.

II. PEMBAYARAN
Demi kelancaran jalannya Kegiatan Belajar Mengajar (KBM) di Sekolah Kristen Saint John, kami bersedia membayar & melunasi semua kewajiban keuangan sesuai dengan ketentuan dan jadwal yang berlaku di Sekolah Kristen Saint John :
2.1 Uang Pangkal Penerimaan Peserta Didik Baru (PPDB)* sesuai dengan ketentuan yang berlaku, sebelum siswa memulai kegiatan belajar di tahun pelajaran baru.
2.2 Uang Sekolah dan Uang Ekskul paling lambat tanggal 10 setiap bulannya.
2.3 Uang Kegiatan sebelum tanggal 30 September. **
2.4 Uang Pendaftaran Ulang sebelum tanggal 31 Maret.**
2.5 Uang buku dan seragam berdasarkan ketentuan dari masing-masing satuan pendidikan.
2.6 Semua uang yang kami sudah bayarkan ke YPK Saint John, kami tidak akan menarik atau meminta kembali dengan alasan apapun
*bagi siswa baru
**sesuai tahun ajaran yang berjalan

III. SANKSI
Di kemudian hari, jika kami tidak memenuhi kewajiban keuangan dalam batas waktu yang telah ditetapkan, maka kami bersedia:
3.1 Memenuhi panggilan berdasarkan Surat Pemanggilan kepada orang tua peserta didik.
3.2 Anak kami tidak mengikuti kegiatan belajar.
3.3 Anak kami tidak ikut dalam kegiatan-kegiatan sekolah apabila belum melunasi Uang Kegiatan.
3.4 Anak kami tidak mendapatkan buku atau seragam.
3.5 Anak kami tidak dapat melanjutkan ke jenjang pendidikan selanjutnya.

Dengan ini, kami menyatakan bahwa kami sudah membaca dan memahami serta menyetujui seluruh isi pernyataan yang ada, sehingga kami tidak akan mengajukan keberatan atau tuntutan apapun kepada pihak Sekolah apabila sanksi di atas dikenakan kepada anak kami. Kami sadar hal tersebut terjadi karena kelalaian kami.
''';

  @override
  void initState() {
    super.initState();
    _selectedAcademicYear = _academicYearOptions.first;
    _syncClassAndSchoolSelection();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _familyCardNumberController.dispose();
    _nikController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  void _syncClassAndSchoolSelection() {
    final classes = _classOptions;
    final schools = _schoolOptions;

    _selectedClass = classes.isNotEmpty ? classes.first : '';
    _selectedSchool = schools.isNotEmpty ? schools.first : '';
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2018),
      firstDate: DateTime(2008),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        _selectedPhoto = photo;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil foto.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPhotoSourceOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text('Upload photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              if (_selectedPhoto != null)
                ListTile(
                  leading: const Icon(Iconsax.trash, color: AppColors.error),
                  title: const Text('Hapus photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedPhoto = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _goToNextStepFromInfoOne() {
    if (!_agreeInfoStepOne) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan centang syarat dan ketentuan terlebih dahulu.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });

    _scrollToTop();
  }

  void _goToNextStepFromInfoTwo() {
    if (!_agreeInfoStepTwo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan centang syarat dan ketentuan terlebih dahulu.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });

    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final now = DateTime.now();
      final createdId = 'std_${now.millisecondsSinceEpoch}';
      final currentUser = ref.read(currentUserProvider);
      final student = Student(
        id: createdId,
        fullName: _fullNameController.text.trim(),
        academicYear: _selectedAcademicYear,
        familyCardNumber: _familyCardNumberController.text.trim(),
        nik: _nikController.text.trim(),
        nisn: createdId,
        schoolLevel: _selectedSchoolLevel,
        grade: _selectedSchoolLevel,
        className: _selectedClass,
        schoolName: _selectedSchool,
        gender: _selectedGender,
        birthDate: _selectedBirthDate ?? now,
        birthPlace: '-',
        address: '-',
        parentPhoneNumber: _parentPhoneController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        parentId: currentUser?.id ?? 'parent_local',
        avatarUrl: _selectedPhoto?.path,
        createdAt: now,
      );

      ref.read(studentsProvider.notifier).addStudent(student);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil dikirim.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = (_currentStep + 1) / 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.studentsRegistrationTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langkah ${_currentStep + 1} dari 3',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _buildInfoStepOne();
      case 1:
        return _buildInfoStepTwo();
      default:
        return _buildRegistrationForm(l10n);
    }
  }

  Widget _buildInfoStepOne() {
    const ageRequirements = [
      ['TK A', '3 tahun 6 bulan'],
      ['TK B', '4 tahun 6 bulan'],
      ['SD', '6 tahun'],
      ['SMP', '12 tahun'],
      ['SMA', '15 tahun'],
    ];

    const adminRequirements = [
      'Mengisi Formulir Online',
      'Foto Akte Kelahiran',
      'Foto Kartu Keluarga',
      'Foto KTP orang tua/wali',
      'Pas foto calon peserta didik ukuran 3 x 4 dengan background warna biru/merah',
      'Surat Perwalian',
    ];

    return Container(
      key: const ValueKey('info-step-one'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Iconsax.info_circle,
            title: 'Informasi Penerimaan',
            subtitle:
                'Pastikan syarat usia dan dokumen calon siswa sudah siap.',
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionCard(
            title: 'Batas Umur',
            subtitle:
                'Batas umur untuk calon murid yang akan bersekolah di St John.',
            child: Column(
              children: ageRequirements
                  .map(
                    (row) => Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.paddingS,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row[0],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            row[1],
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildSectionCard(
            title: 'Keperluan Administrasi',
            subtitle:
                'Siapkan dokumen berikut sebelum melanjutkan pendaftaran.',
            child: Column(
              children: adminRequirements
                  .map((item) => _buildChecklistTile(text: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          const Padding(
            padding: EdgeInsets.only(left: AppDimensions.paddingXS),
            child: Text(
              '*Jika tidak tinggal dengan orang tua',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildAgreementCard(
            value: _agreeInfoStepOne,
            text: 'Saya menyetujui syarat dan ketentuan informasi di atas.',
            onChanged: (value) {
              setState(() {
                _agreeInfoStepOne = value;
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingM),
          PrimaryButton(
            text: 'Lanjut ke Pernyataan',
            onPressed: _goToNextStepFromInfoOne,
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 250));
  }

  Widget _buildInfoStepTwo() {
    return Container(
      key: const ValueKey('info-step-two'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Iconsax.document_text,
            title: 'Pernyataan Orang Tua',
            subtitle: 'Mohon baca seluruh dokumen persetujuan sebelum lanjut.',
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionCard(
            title: 'Ringkasan Dokumen',
            subtitle: 'Poin utama yang perlu diperhatikan:',
            child: Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children: [
                _buildInfoBadge(
                  icon: Iconsax.shield,
                  label: 'Peraturan',
                  value: '7 poin',
                ),
                _buildInfoBadge(
                  icon: Iconsax.wallet_2,
                  label: 'Pembayaran',
                  value: '6 poin',
                ),
                _buildInfoBadge(
                  icon: Iconsax.warning_2,
                  label: 'Sanksi',
                  value: '5 poin',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildSectionCard(
            title: 'Dokumen Persetujuan Lengkap',
            subtitle: 'Baca sampai selesai sebelum menandai persetujuan.',
            child: const Text(
              _infoStepTwoContent,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildAgreementCard(
            value: _agreeInfoStepTwo,
            text: 'Saya sudah membaca dan menyetujui seluruh isi pernyataan.',
            onChanged: (value) {
              setState(() {
                _agreeInfoStepTwo = value;
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingM),
          PrimaryButton(
            text: 'Lanjut ke Form Registrasi',
            onPressed: _goToNextStepFromInfoTwo,
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 250));
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
          if (subtitle != null) ...[
            const SizedBox(height: AppDimensions.paddingXS),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.paddingM),
          child,
        ],
      ),
    );
  }

  Widget _buildChecklistTile({required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.tick_circle, size: 16, color: AppColors.primary),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCard({
    required bool value,
    required String text,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      onTap: () => onChanged(!value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: value ? 0.1 : 0.04),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Container(
        key: const ValueKey('registration-form'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoPickerSection(),
            const SizedBox(height: AppDimensions.paddingL),
            _buildDropdown(
              label: 'Tahun ajaran',
              value: _selectedAcademicYear,
              items: _academicYearOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedAcademicYear = value;
                });
              },
              icon: Iconsax.calendar,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _familyCardNumberController,
              label: 'Nomor Kartu Keluarga',
              hint: 'Masukkan nomor kartu keluarga',
              prefixIcon: Iconsax.card,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _nikController,
              label: 'NIK',
              hint: 'Masukkan NIK',
              prefixIcon: Iconsax.personalcard,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _fullNameController,
              label: 'Nama Lengkap (Berdasarkan Akta)',
              hint: 'Masukkan nama lengkap',
              prefixIcon: Iconsax.user,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _birthDateController,
              label: 'Tanggal Lahir',
              hint: 'Pilih tanggal lahir',
              prefixIcon: Iconsax.calendar,
              readOnly: true,
              onTap: _selectBirthDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildDropdown(
              label: 'Jenis Kelamin',
              value: _selectedGender,
              items: _genderOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedGender = value;
                });
              },
              icon: Iconsax.user,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildDropdown(
              label: 'Tingkat Sekolah',
              value: _selectedSchoolLevel,
              items: _schoolLevelOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSchoolLevel = value;
                  _syncClassAndSchoolSelection();
                });
              },
              icon: Iconsax.buildings,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildDropdown(
              label: 'Kelas',
              value: _selectedClass,
              items: _classOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedClass = value;
                });
              },
              icon: Iconsax.teacher,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildDropdown(
              label: 'Sekolah',
              value: _selectedSchool,
              items: _schoolOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSchool = value;
                });
              },
              icon: Iconsax.building,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _parentPhoneController,
              label: 'Nomor telp orang tua',
              hint: 'Masukkan nomor telepon orang tua',
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildDropdown(
              label: 'Metode Pembayaran',
              value: _selectedPaymentMethod,
              items: _paymentMethodOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              icon: Iconsax.wallet,
            ),
            const SizedBox(height: AppDimensions.paddingXXL),
            PrimaryButton(
              text: 'Selesai',
              isLoading: _isLoading,
              onPressed: _submitRegistration,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 250));
  }

  Widget _buildPhotoPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo calon siswa (opsional)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Center(
          child: GestureDetector(
            onTap: _showPhotoSourceOptions,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: ClipOval(
                child: _selectedPhoto != null
                    ? Image.file(
                        File(_selectedPhoto!.path),
                        fit: BoxFit.cover,
                        width: 110,
                        height: 110,
                      )
                    : const Icon(
                        Iconsax.profile_circle,
                        size: 58,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildPhotoActionButton(
                text: 'Upload photo',
                icon: Iconsax.gallery,
                onPressed: () => _pickPhoto(ImageSource.gallery),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: _buildPhotoActionButton(
                text: 'Take photo',
                icon: Iconsax.camera,
                onPressed: () => _pickPhoto(ImageSource.camera),
              ),
            ),
          ],
        ),
        if (_selectedPhoto != null) ...[
          const SizedBox(height: AppDimensions.paddingS),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedPhoto = null;
                });
              },
              icon: const Icon(Iconsax.trash, size: 16),
              label: const Text('Hapus photo'),
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.paddingXS),
        const Text(
          'Jika tidak upload, foto default akan digunakan.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          maximumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: AppDimensions.paddingXS),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
            ),
            icon: const Icon(Iconsax.arrow_down_1, size: 20),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
