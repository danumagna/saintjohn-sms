import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Contact Us screen with school contact information and message form.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Future<void> _launchUrl(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final uri = Uri.parse(url);
    final isLaunched = await launchUrl(uri, mode: mode);
    if (!isLaunched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Contact Us'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Cards
            Text(
              'Reach Us',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
            const SizedBox(height: AppDimensions.paddingM),
            _buildContactCard(
              icon: Iconsax.location,
              title: 'Address',
              value:
                  'Jl. Bungur Besar Raya No. 82a - 84, RT.1/RW.7, Gn. Sahari Sel., Kec. Kemayoran, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10610',
              onTap: () =>
                  _launchUrl('https://maps.app.goo.gl/BdVbr4U4ewLDLMz1A'),
            ),
            _buildContactCard(
              icon: Iconsax.call,
              title: 'Phone',
              value: '+62 21 1234 5678',
              onTap: () => _launchUrl(
                'tel:+622112345678',
                mode: LaunchMode.externalApplication,
              ),
            ),
            _buildContactCard(
              icon: Iconsax.sms,
              title: 'Email',
              value: 'info@saintjohnschool.edu',
              onTap: () => _launchUrl(
                'mailto:info@saintjohnschool.edu',
                mode: LaunchMode.externalApplication,
              ),
            ),
            _buildContactCard(
              icon: Iconsax.clock,
              title: 'Office Hours',
              value: 'Monday - Friday\n06:30 - 18:00 WIB',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
          elevation: AppDimensions.elevationS,
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Icon(icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, end: 0);
  }
}



