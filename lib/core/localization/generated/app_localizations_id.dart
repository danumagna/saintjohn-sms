// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Saint John SMS';

  @override
  String get appFullName => 'Saint John School Management System';

  @override
  String get authLoginTitle => 'Masuk';

  @override
  String get authLoginAsParent => 'Masuk sebagai Orang Tua';

  @override
  String get authLoginAsStudent => 'Masuk sebagai Siswa';

  @override
  String get authEmailHint => 'Masukkan email Anda';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordHint => 'Masukkan kata sandi Anda';

  @override
  String get authPasswordLabel => 'Kata Sandi';

  @override
  String get authRememberMe => 'Ingat saya';

  @override
  String get authForgotPassword => 'Lupa Kata Sandi?';

  @override
  String get authLogin => 'Masuk';

  @override
  String get authNoAccount => 'Belum punya akun?';

  @override
  String get authSignUp => 'Daftar';

  @override
  String get authSignUpTitle => 'Buat Akun';

  @override
  String get authFullNameHint => 'Masukkan nama lengkap Anda';

  @override
  String get authFullNameLabel => 'Nama Lengkap';

  @override
  String get authPhoneHint => 'Masukkan nomor telepon Anda';

  @override
  String get authPhoneLabel => 'Nomor Telepon';

  @override
  String get authConfirmPasswordHint => 'Konfirmasi kata sandi Anda';

  @override
  String get authConfirmPasswordLabel => 'Konfirmasi Kata Sandi';

  @override
  String get authAgreeTerms => 'Saya setuju dengan Syarat & Ketentuan';

  @override
  String get authHaveAccount => 'Sudah punya akun?';

  @override
  String get authForgotPasswordTitle => 'Lupa Kata Sandi';

  @override
  String get authForgotPasswordDesc =>
      'Masukkan alamat email Anda dan kami akan mengirimkan link untuk mengatur ulang kata sandi.';

  @override
  String get authSendResetLink => 'Kirim Link Reset';

  @override
  String get authBackToLogin => 'Kembali ke Login';

  @override
  String dashboardWelcome(String name) {
    return 'Selamat Datang, $name';
  }

  @override
  String get dashboardTitle => 'Beranda';

  @override
  String get menuStudents => 'Siswa';

  @override
  String get menuStudentRegistration => 'Pendaftaran';

  @override
  String get menuStudentList => 'Daftar Siswa';

  @override
  String get menuGuide => 'Panduan';

  @override
  String get menuContactUs => 'Hubungi Kami';

  @override
  String get menuAssessment => 'Penilaian';

  @override
  String get menuSchedule => 'Jadwal Pelajaran';

  @override
  String get menuAcademicCalendar => 'Kalender Akademik';

  @override
  String get menuReports => 'Laporan';

  @override
  String get menuAttendance => 'Kehadiran Siswa';

  @override
  String get menuExamSchedule => 'Jadwal Ujian Hari Ini';

  @override
  String get menuSessionAttendance => 'Kehadiran per Sesi Hari Ini';

  @override
  String get menuStudentProgress => 'Progress Pencapaian Siswa';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsMyProfile => 'Profil Saya';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsNotifications => 'Notifikasi';

  @override
  String get settingsAbout => 'Tentang Aplikasi';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String get settingsLogoutConfirm => 'Apakah Anda yakin ingin keluar?';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get notificationsEmpty => 'Belum ada notifikasi';

  @override
  String get notificationsMarkAllRead => 'Tandai semua sudah dibaca';

  @override
  String get commonSubmit => 'Kirim';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonLoading => 'Memuat...';

  @override
  String get commonError => 'Terjadi kesalahan';

  @override
  String get commonRetry => 'Coba Lagi';

  @override
  String get commonYes => 'Ya';

  @override
  String get commonNo => 'Tidak';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonSearch => 'Cari';

  @override
  String get commonNoData => 'Tidak ada data';

  @override
  String get validationRequired => 'Kolom ini wajib diisi';

  @override
  String get validationEmail => 'Masukkan email yang valid';

  @override
  String get validationPasswordMin => 'Kata sandi minimal 8 karakter';

  @override
  String get validationPasswordMatch => 'Kata sandi tidak cocok';

  @override
  String get validationPhone => 'Masukkan nomor telepon yang valid';

  @override
  String get studentsListTitle => 'Daftar Siswa';

  @override
  String get studentsSearchHint => 'Cari berdasarkan nama atau NISN';

  @override
  String get studentsEmptyState => 'Tidak ada siswa ditemukan';

  @override
  String get studentsRegistrationTitle => 'Pendaftaran Siswa';

  @override
  String get studentsFullName => 'Nama Lengkap';

  @override
  String get studentsFullNameHint => 'Masukkan nama lengkap siswa';

  @override
  String get studentsNISN => 'NISN';

  @override
  String get studentsNISNHint => 'Masukkan NISN';

  @override
  String get studentsGender => 'Jenis Kelamin';

  @override
  String get studentsBirthDate => 'Tanggal Lahir';

  @override
  String get studentsBirthDateHint => 'Pilih tanggal lahir';

  @override
  String get studentsGrade => 'Kelas';

  @override
  String get studentsClass => 'Ruang Kelas';

  @override
  String get studentsAddress => 'Alamat';

  @override
  String get studentsAddressHint => 'Masukkan alamat siswa';

  @override
  String get studentsRegisterButton => 'Daftarkan Siswa';

  @override
  String get guideTitle => 'Panduan';

  @override
  String get contactTitle => 'Hubungi Kami';

  @override
  String get contactReachUs => 'Hubungi Kami';

  @override
  String get contactAddress => 'Alamat';

  @override
  String get contactPhone => 'Telepon';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactOfficeHours => 'Jam Kerja';

  @override
  String get contactSendMessage => 'Kirim Pesan';

  @override
  String get contactSubject => 'Subjek';

  @override
  String get contactSubjectHint => 'Masukkan subjek pesan';

  @override
  String get contactMessage => 'Pesan';

  @override
  String get contactMessageHint => 'Masukkan pesan Anda';

  @override
  String get contactSendButton => 'Kirim Pesan';

  @override
  String get assessmentTitle => 'Penilaian';

  @override
  String get assessmentAll => 'Semua';

  @override
  String get assessmentExams => 'Ujian';

  @override
  String get assessmentAssignments => 'Tugas';

  @override
  String get assessmentAverage => 'Rata-rata';

  @override
  String get assessmentTotal => 'Total';

  @override
  String get assessmentRank => 'Peringkat';

  @override
  String get scheduleTitle => 'Jadwal Pelajaran';

  @override
  String get calendarTitle => 'Kalender Akademik';

  @override
  String get calendarNoEvents => 'Tidak ada acara untuk hari ini';

  @override
  String get reportAttendance => 'Laporan Kehadiran';

  @override
  String get reportAttendanceRate => 'Tingkat Kehadiran';

  @override
  String get reportPresent => 'Hadir';

  @override
  String get reportAbsent => 'Tidak Hadir';

  @override
  String get reportLate => 'Terlambat';

  @override
  String get reportExcused => 'Izin';

  @override
  String get reportExamSchedule => 'Jadwal Ujian';

  @override
  String get reportTodayExams => 'Ujian Hari Ini';

  @override
  String get reportUpcomingExams => 'Ujian Mendatang';

  @override
  String get reportNoExams => 'Tidak ada jadwal ujian';

  @override
  String get reportSessionAttendance => 'Kehadiran per Sesi';

  @override
  String get reportTodayAttendance => 'Kehadiran Hari Ini';

  @override
  String get reportOngoing => 'Berlangsung';

  @override
  String get reportUpcoming => 'Mendatang';

  @override
  String get reportProgress => 'Progress Siswa';

  @override
  String get reportOverall => 'Keseluruhan';

  @override
  String get reportAcademicProgress => 'Progress Akademik';

  @override
  String get reportSubjects => 'Mata Pelajaran';

  @override
  String get reportAvgGrade => 'Rata-rata';

  @override
  String get reportSubjectProgress => 'Progress per Mata Pelajaran';

  @override
  String get reportTopics => 'topik';

  @override
  String get reportAchievements => 'Pencapaian';

  @override
  String get reportTopPerformer => 'Nilai Tertinggi';

  @override
  String get reportMostImproved => 'Peningkatan Terbaik';
}
