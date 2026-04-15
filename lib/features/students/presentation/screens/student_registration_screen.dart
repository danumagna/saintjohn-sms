import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../routing/app_router.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/registration_payment_args.dart';
import '../../data/repositories/students_repository.dart';
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
  final _familyCardNumberController = TextEditingController();
  final _nikController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  int _currentStep = 0;
  bool _agreeInfoStepOne = false;
  bool _agreeInfoStepTwo = false;
  bool _isLoading = false;

  DateTime? _selectedBirthDate;

  int? _selectedAcademicYearId;
  String _selectedGender = 'Laki - Laki';
  int? _selectedSchoolLevelId;
  int? _selectedClassId;
  int? _selectedSchoolId;
  int? _selectedPaymentMethodId;

  final List<String> _genderOptions = ['Laki - Laki', 'Perempuan'];

  int? _effectiveMasterSelection({
    required int? currentId,
    required List<MasterOption> options,
  }) {
    if (currentId != null && options.any((item) => item.id == currentId)) {
      return currentId;
    }
    return options.isNotEmpty ? options.first.id : null;
  }

  MasterOption? _findById(List<MasterOption> options, int? id) {
    if (id == null) {
      return null;
    }

    for (final option in options) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  String _schoolLevelKeyFor(String value) {
    final normalized = value.trim().toUpperCase();

    if (normalized.contains('SMP')) {
      return 'SMP';
    }
    if (normalized.contains('SMA')) {
      return 'SMA';
    }
    if (normalized.contains('SD')) {
      return 'SD';
    }
    if (normalized.contains('TK')) {
      return 'TK';
    }
    if (normalized.contains('KB')) {
      return 'KB';
    }

    return normalized;
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
  void dispose() {
    _scrollController.dispose();
    _familyCardNumberController.dispose();
    _nikController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  void _syncClassAndSchoolSelection({
    required List<MasterOption> allClassOptions,
    required List<MasterOption> allSchoolOptions,
    required String selectedLevel,
  }) {
    final classes = _classOptionsForLevel(
      allClassOptions,
      selectedLevel: selectedLevel,
    );
    final schools = _schoolOptionsForLevel(
      allSchoolOptions,
      selectedLevel: selectedLevel,
    );

    _selectedClassId = classes.isNotEmpty ? classes.first.id : null;
    _selectedSchoolId = schools.isNotEmpty ? schools.first.id : null;
  }

  List<MasterOption> _classOptionsForLevel(
    List<MasterOption> options, {
    String? selectedLevel,
  }) {
    final key = _schoolLevelKeyFor(selectedLevel ?? '').toLowerCase();
    return options.where((item) => _isClassMatchLevel(item.name, key)).toList();
  }

  bool _isClassMatchLevel(String className, String levelKey) {
    final normalized = className.trim().toLowerCase();

    if (levelKey == 'kb') {
      return normalized.contains('kelompok bermain') ||
          normalized.startsWith('kb');
    }

    if (levelKey == 'tk') {
      return normalized.startsWith('tk');
    }

    final match = RegExp(r'kelas\s*(\d+)').firstMatch(normalized);
    final classNumber = int.tryParse(match?.group(1) ?? '');
    if (classNumber == null) {
      return false;
    }

    if (levelKey == 'sd') {
      return classNumber >= 1 && classNumber <= 6;
    }
    if (levelKey == 'smp') {
      return classNumber >= 7 && classNumber <= 9;
    }
    if (levelKey == 'sma') {
      return classNumber >= 10 && classNumber <= 12;
    }

    return false;
  }

  List<MasterOption> _schoolOptionsForLevel(
    List<MasterOption> options, {
    String? selectedLevel,
  }) {
    final key = _schoolLevelKeyFor(selectedLevel ?? '').toLowerCase();
    final sanitizedOptions = options.where((item) {
      final displayName = item.name.trim();
      if (displayName.isEmpty || _isNumericOnly(displayName)) {
        return false;
      }

      return true;
    }).toList();

    final filteredByLevel = sanitizedOptions.where((item) {
      if (!_isSchoolMatchLevel(item, key)) {
        return false;
      }

      if (key == 'tk') {
        final normalizedName = item.name.trim().toLowerCase();
        final code = (item.code ?? '').toUpperCase();
        final hasTkName =
            _containsLevelFamily(normalizedName, 'tk') ||
            normalizedName.startsWith('taman kanak');
        final hasTkCode = code.contains('UNITTK');

        return hasTkName || hasTkCode;
      }

      return true;
    }).toList();

    if (key == 'tk') {
      return filteredByLevel;
    }

    // Non-TK fallback: if backend naming is unusual, avoid empty dropdown.
    return filteredByLevel.isNotEmpty ? filteredByLevel : sanitizedOptions;
  }

  bool _isNumericOnly(String value) {
    return RegExp(r'^\d+$').hasMatch(value.trim());
  }

  bool _containsLevelKeyword(String text, String keyword) {
    final normalized = text.toLowerCase();
    return RegExp('\\b$keyword\\b').hasMatch(normalized);
  }

  bool _containsLevelFamily(String text, String keyword) {
    final normalized = text.toLowerCase();
    return _containsLevelKeyword(normalized, keyword) ||
        RegExp('\\b$keyword[a-z]*\\b').hasMatch(normalized);
  }

  bool _isSchoolMatchLevel(MasterOption school, String levelKey) {
    final normalizedName = school.name.toLowerCase();
    final normalizedCode = (school.code ?? '').toUpperCase();

    if (levelKey == 'kb') {
      return normalizedCode.contains('UNITKB') ||
          _containsLevelKeyword(normalizedName, 'kb') ||
          normalizedName.contains('kelompok bermain');
    }

    if (levelKey == 'tk') {
      final fromCode = normalizedCode.contains('UNITTK');
      final fromName =
          _containsLevelFamily(normalizedName, 'tk') ||
          normalizedName.startsWith('taman kanak');

      // Guard: reject rows that also look like other levels (common bad master rows).
      final hasOtherLevel =
          _containsLevelFamily(normalizedName, 'sd') ||
          _containsLevelFamily(normalizedName, 'smp') ||
          _containsLevelFamily(normalizedName, 'sma') ||
          normalizedCode.contains('UNITSD') ||
          normalizedCode.contains('UNITSMP') ||
          normalizedCode.contains('UNITSMA');

      return (fromCode || fromName) && !hasOtherLevel;
    }

    if (levelKey == 'sd') {
      return normalizedCode.contains('UNITSD') ||
          _containsLevelFamily(normalizedName, 'sd');
    }

    if (levelKey == 'smp') {
      return normalizedCode.contains('UNITSMP') ||
          _containsLevelFamily(normalizedName, 'smp');
    }

    if (levelKey == 'sma') {
      return normalizedCode.contains('UNITSMA') ||
          _containsLevelFamily(normalizedName, 'sma');
    }

    return false;
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

    final masters = ref.read(studentRegistrationMastersProvider).asData?.value;
    final academicYearOptions =
        masters?.academicYears ?? const <MasterOption>[];
    final schoolLevelOptions = masters?.schoolLevels ?? const <MasterOption>[];
    final classSourceOptions = masters?.schoolGrades ?? const <MasterOption>[];
    final schoolSourceOptions = masters?.schoolUnits ?? const <MasterOption>[];
    final paymentMethodOptions =
        masters?.paymentMethods ?? const <MasterOption>[];

    final effectiveSchoolLevelId = _effectiveMasterSelection(
      currentId: _selectedSchoolLevelId,
      options: schoolLevelOptions,
    );
    final effectiveSchoolLevelOption = _findById(
      schoolLevelOptions,
      effectiveSchoolLevelId,
    );
    final effectiveSchoolLevel = effectiveSchoolLevelOption?.name ?? '';

    final effectiveClassOptions = _classOptionsForLevel(
      classSourceOptions,
      selectedLevel: effectiveSchoolLevel,
    );
    final effectiveSchoolOptions = _schoolOptionsForLevel(
      schoolSourceOptions,
      selectedLevel: effectiveSchoolLevel,
    );

    final effectiveAcademicYearId = _effectiveMasterSelection(
      currentId: _selectedAcademicYearId,
      options: academicYearOptions,
    );
    final effectiveClassId = _effectiveMasterSelection(
      currentId: _selectedClassId,
      options: effectiveClassOptions,
    );
    final effectiveSchoolId = _effectiveMasterSelection(
      currentId: _selectedSchoolId,
      options: effectiveSchoolOptions,
    );
    final effectivePaymentMethodId = _effectiveMasterSelection(
      currentId: _selectedPaymentMethodId,
      options: paymentMethodOptions,
    );

    final effectiveAcademicYear = _findById(
      academicYearOptions,
      effectiveAcademicYearId,
    );
    final effectiveClass = _findById(effectiveClassOptions, effectiveClassId);
    final effectiveSchool = _findById(
      effectiveSchoolOptions,
      effectiveSchoolId,
    );
    final effectivePaymentMethod = _findById(
      paymentMethodOptions,
      effectivePaymentMethodId,
    );

    if (effectiveAcademicYear == null ||
        effectiveAcademicYear.id == null ||
        effectiveSchoolLevelOption == null ||
        effectiveSchoolLevelOption.id == null ||
        effectiveClass == null ||
        effectiveClass.id == null ||
        effectiveSchool == null ||
        effectiveSchool.id == null ||
        effectivePaymentMethod == null ||
        effectivePaymentMethod.id == null ||
        effectiveSchoolLevel.isEmpty ||
        effectiveClass.name.isEmpty ||
        effectiveSchool.name.isEmpty ||
        effectivePaymentMethod.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data master dari API belum tersedia.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final effectiveBirthDate = _selectedBirthDate ?? DateTime.now();
    final payload = <String, dynamic>{
      'action': 'Regfee',
      'createBy': currentUser?.fullName ?? '-',
      'dateOfBirth': DateFormat('yyyy-MM-dd').format(effectiveBirthDate),
      'emailParent': currentUser?.email ?? '-',
      'familyCardNumber': _familyCardNumberController.text.trim(),
      'gender': _selectedGender.toLowerCase().contains('perempuan')
          ? 'female'
          : 'male',
      'namaParent': currentUser?.fullName ?? '-',
      'nidParentUser': int.tryParse(currentUser?.id ?? '') ?? 0,
      'nik': _nikController.text.trim(),
      'paymentMethod': effectivePaymentMethod.id,
      'phoneNumber': _parentPhoneController.text.trim(),
      'schoolGrade': effectiveClass.id,
      'schoolLevel': effectiveSchoolLevelOption.id,
      'schoolUnit': effectiveSchool.id,
      'schoolYear': effectiveAcademicYear.id,
      'studentFeePayment': 0,
      'vSchoolGrade': effectiveClass.name,
      'vSchoolLevel': effectiveSchoolLevelOption.name,
      'virtualAccountNumber': null,
    };

    setState(() => _isLoading = true);
    if (!mounted) return;

    try {
      await context.push(
        AppRoutes.studentRegistrationPayment,
        extra: RegistrationPaymentArgs(
          fullName: _fullNameController.text.trim(),
          schoolLevel: effectiveSchoolLevel,
          className: effectiveClass.name,
          schoolName: effectiveSchool.name,
          registrationPricePayload: payload,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Student Registration'),
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
                child: _buildStepContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildInfoStepOne();
      case 1:
        return _buildInfoStepTwo();
      default:
        return _buildRegistrationForm();
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

  Widget _buildRegistrationForm() {
    final mastersAsync = ref.watch(studentRegistrationMastersProvider);
    final masters = mastersAsync.asData?.value;
    final isMastersLoading = mastersAsync.isLoading && masters == null;

    final academicYearOptions =
        masters?.academicYears ?? const <MasterOption>[];
    final schoolLevelOptions = masters?.schoolLevels ?? const <MasterOption>[];
    final classSourceOptions = masters?.schoolGrades ?? const <MasterOption>[];
    final schoolSourceOptions = masters?.schoolUnits ?? const <MasterOption>[];
    final paymentMethodOptions =
        masters?.paymentMethods ?? const <MasterOption>[];

    final selectedAcademicYearId = _effectiveMasterSelection(
      currentId: _selectedAcademicYearId,
      options: academicYearOptions,
    );
    final selectedSchoolLevelId = _effectiveMasterSelection(
      currentId: _selectedSchoolLevelId,
      options: schoolLevelOptions,
    );
    final selectedSchoolLevelOption = _findById(
      schoolLevelOptions,
      selectedSchoolLevelId,
    );
    final selectedSchoolLevel = selectedSchoolLevelOption?.name ?? '';

    final classOptions = _classOptionsForLevel(
      classSourceOptions,
      selectedLevel: selectedSchoolLevel,
    );
    final schoolOptions = _schoolOptionsForLevel(
      schoolSourceOptions,
      selectedLevel: selectedSchoolLevel,
    );

    final selectedClassId = _effectiveMasterSelection(
      currentId: _selectedClassId,
      options: classOptions,
    );
    final selectedSchoolId = _effectiveMasterSelection(
      currentId: _selectedSchoolId,
      options: schoolOptions,
    );
    final selectedPaymentMethodId = _effectiveMasterSelection(
      currentId: _selectedPaymentMethodId,
      options: paymentMethodOptions,
    );

    return Form(
      key: _formKey,
      child: Container(
        key: const ValueKey('registration-form'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mastersAsync.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: LinearProgressIndicator(minHeight: 4),
              ),
            if (isMastersLoading)
              _buildMasterDropdownSkeleton(label: 'Tahun ajaran')
            else
              _buildMasterDropdown(
                label: 'Tahun ajaran',
                value: selectedAcademicYearId,
                items: academicYearOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedAcademicYearId = value;
                  });
                },
                icon: Iconsax.calendar,
              ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _familyCardNumberController,
              label: 'Nomor Kartu Keluarga',
              hint: 'Masukkan nomor kartu keluarga (16 digit)',
              prefixIcon: Iconsax.card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (value.length != 16) {
                  return 'Nomor Kartu Keluarga harus 16 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _nikController,
              label: 'NIK',
              hint: 'Masukkan NIK (16 digit)',
              prefixIcon: Iconsax.personalcard,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingS),
            const Text(
              'Nomor Kartu Keluarga dan NIK wajib 16 digit.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AppTextField(
              controller: _fullNameController,
              label: 'Nama Lengkap (Berdasarkan Akta)',
              hint: 'Masukkan nama lengkap',
              prefixIcon: Iconsax.user,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
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
                  return 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildStringDropdown(
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
            if (isMastersLoading)
              _buildMasterDropdownSkeleton(label: 'Tingkat Sekolah')
            else
              _buildMasterDropdown(
                label: 'Tingkat Sekolah',
                value: selectedSchoolLevelId,
                items: schoolLevelOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedSchoolLevelId = value;

                    final selectedOption = _findById(schoolLevelOptions, value);

                    _syncClassAndSchoolSelection(
                      allClassOptions: classSourceOptions,
                      allSchoolOptions: schoolSourceOptions,
                      selectedLevel: selectedOption?.name ?? '',
                    );
                  });
                },
                icon: Iconsax.buildings,
              ),
            const SizedBox(height: AppDimensions.paddingM),
            if (isMastersLoading)
              _buildMasterDropdownSkeleton(label: 'Kelas')
            else
              _buildMasterDropdown(
                label: 'Kelas',
                value: selectedClassId,
                items: classOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                  });
                },
                icon: Iconsax.teacher,
              ),
            const SizedBox(height: AppDimensions.paddingM),
            if (isMastersLoading)
              _buildMasterDropdownSkeleton(label: 'Sekolah')
            else
              _buildMasterDropdown(
                label: 'Sekolah',
                value: selectedSchoolId,
                items: schoolOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedSchoolId = value;
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
                  return 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (isMastersLoading)
              _buildMasterDropdownSkeleton(label: 'Metode Pembayaran')
            else
              _buildMasterDropdown(
                label: 'Metode Pembayaran',
                value: selectedPaymentMethodId,
                items: paymentMethodOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethodId = value;
                  });
                },
                icon: Iconsax.wallet,
              ),
            const SizedBox(height: AppDimensions.paddingXXL),
            PrimaryButton(
              text: 'Next',
              isLoading: _isLoading,
              onPressed: _submitRegistration,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 250));
  }

  Widget _buildMasterDropdown({
    required String label,
    required int? value,
    required List<MasterOption> items,
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    final safeValue = value != null && items.any((item) => item.id == value)
        ? value
        : null;

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
          child: DropdownButtonFormField<int>(
            initialValue: safeValue,
            isExpanded: true,
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
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: items.isEmpty ? null : onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildStringDropdown({
    required String label,
    required String? value,
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
            isExpanded: true,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: items.isEmpty ? null : onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMasterDropdownSkeleton({required String label}) {
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
        Shimmer.fromColors(
          baseColor: AppColors.borderLight,
          highlightColor: AppColors.surface,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }
}






