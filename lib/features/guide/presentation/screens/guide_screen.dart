import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Guide screen with help and tutorial information.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const String _websiteUrl = 'https://stjohn.magnaedu.id/';
  static const String _youtubeGuideUrl =
      'https://www.youtube.com/watch?v=K3kztVRbTss&embeds_referring_euri=https%3A%2F%2Fdev.magnaedu.id%2F&source_ve_path=OTY3MTQ';
  static const String _youtubeFallbackUrl =
      'https://www.youtube.com/watch?v=K3kztVRbTss';

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    // Prefer opening in an external app/browser so users are redirected directly.
    bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) {
      opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
    }

    // Fallback for YouTube links with long tracking params.
    if (!opened && url == _youtubeGuideUrl) {
      final fallbackUri = Uri.parse(_youtubeFallbackUrl);
      opened = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      );
    }

    if (opened) {
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link tidak dapat dibuka.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final guides = [
      _GuideStep(
        title: 'Membuat Akun',
        content:
            'Calon orang tua / wali siswa dapat mengakses link website, lalu registrasi akun dengan cara klik "Daftar".',
        linkLabel: _websiteUrl,
        linkUrl: _websiteUrl,
      ),
      const _GuideStep(
        title: 'Aktivasi Akun',
        content:
            'Setelah calon orang tua / wali siswa berhasil membuat akun, cek email dan akan ada pesan yang masuk untuk aktivasi akun.',
      ),
      const _GuideStep(
        title: 'Masuk Akun',
        content:
            'Calon orang tua / wali siswa masuk ke akun dengan cara klik "Masuk Akun Orang Tua" di halaman beranda website menggunakan email dan password yang sudah dibuat.',
      ),
      const _GuideStep(
        title: 'Pembayaran Pendaftaran',
        content:
            'Isi formulir registrasi calon siswa baru dan lakukan pembayaran pendaftaran melalui nomor virtual account ataupun transfer bank yang tersedia. Jika menggunakan nomor virtual account maka orang tua harus menunggu admin untuk input nomor virtual account.',
      ),
      const _GuideStep(
        title: 'Isi Formulir Pendaftaran Siswa',
        content:
            'Setelah pembayaran pendaftaran lunas, maka akan memunculkan data profil, informasi tes, status pembayaran uang pangkal. Klik data profil dan isi data wajib pada formulir lalu upload Surat Pernyataan.',
      ),
      const _GuideStep(
        title: 'Tes Seleksi',
        content:
            'Pada bagian beranda orang tua, informasi tes digunakan orang tua/calon siswa untuk mengetahui jadwal tes dan terdapat beberapa status. Jika status menunggu maka belum terdapat jadwal dan jika status diumumkan maka sudah terdapat jadwal tes.',
      ),
      const _GuideStep(
        title: 'Hasil Tes',
        content:
            'Setelah tahap tes dilakukan, maka status informasi tes berubah. Jika status lulus maka lanjutkan tahap berikutnya. Jika status tidak lulus maka lakukan registrasi ulang dan jika negosiasi maka orang tua calon siswa melakukan negosiasi dengan bagian registrasi.',
      ),
      const _GuideStep(
        title: 'Pembayaran Uang Gedung',
        content:
            'Jika calon siswa lulus, maka klik Status Pembayaran Uang Pangkal dan isi metode pembayaran yang diinginkan. Jika menggunakan nomor virtual account maka orang tua harus menunggu admin untuk input nomor virtual account.',
      ),
      const _GuideStep(
        title: 'Penerimaan Sebagai Siswa',
        content:
            'Setelah lunas pembayaran formulir, data profil lengkap, calon siswa lulus tes dan pembayaran uang pangkal lunas, maka sekolah akan memutuskan calon siswa menjadi siswa resmi Saint John.',
      ),
      const _GuideStep(
        title: 'Lengkapi Data Profil',
        content:
            'Calon siswa yang sudah menjadi siswa, akan berubah tampilan pada beranda orang tua dan terdapat profil yang dapat dilengkapi, serta dashboard untuk melihat aktivitas sekolah siswa.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.guideTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...guides.asMap().entries.map((entry) {
              return _buildGuideCard(
                context: context,
                number: entry.key + 1,
                step: entry.value,
                index: entry.key,
              );
            }),
            const SizedBox(height: AppDimensions.paddingL),
            _buildYoutubeCard(context).animate().fadeIn(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required BuildContext context,
    required int number,
    required _GuideStep step,
    required int index,
  }) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(AppDimensions.paddingM),
              childrenPadding: const EdgeInsets.only(
                left: AppDimensions.paddingL,
                right: AppDimensions.paddingL,
                bottom: AppDimensions.paddingM,
              ),
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              title: Text(
                step.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              children: [
                Text(
                  step.content,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (step.linkUrl != null && step.linkLabel != null) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  InkWell(
                    onTap: () => _launchUrl(context, step.linkUrl!),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingXS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.link_2,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Flexible(
                            child: Text(
                              step.linkLabel!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildYoutubeCard(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link YouTube untuk panduan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXS),
            const Text(
              'Cara daftar di Sekolah Kristen Saint John',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            InkWell(
              onTap: () => _launchUrl(context, _youtubeGuideUrl),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingXS,
                ),
                child: Text(
                  _youtubeGuideUrl,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _launchUrl(context, _youtubeGuideUrl),
                icon: const Icon(Iconsax.play, size: 18),
                label: const Text('Buka video panduan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep {
  final String title;
  final String content;
  final String? linkLabel;
  final String? linkUrl;

  const _GuideStep({
    required this.title,
    required this.content,
    this.linkLabel,
    this.linkUrl,
  });
}
