import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Contact Us screen with school contact information and message form.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      _subjectController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.contactTitle),
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
              l10n.contactReachUs,
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
              title: l10n.contactAddress,
              value:
                  'Jl. Bungur Besar Raya No. 82a - 84, RT.1/RW.7, Gn. Sahari Sel., Kec. Kemayoran, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10610',
              onTap: () =>
                  _launchUrl('https://maps.app.goo.gl/BdVbr4U4ewLDLMz1A'),
            ),
            _buildContactCard(
              icon: Iconsax.call,
              title: l10n.contactPhone,
              value: '+62 21 1234 5678',
              onTap: () => _launchUrl('tel:+622112345678'),
            ),
            _buildContactCard(
              icon: Iconsax.sms,
              title: l10n.contactEmail,
              value: 'info@saintjohnschool.edu',
              onTap: () => _launchUrl('mailto:info@saintjohnschool.edu'),
            ),
            _buildContactCard(
              icon: Iconsax.clock,
              title: l10n.contactOfficeHours,
              value: 'Monday - Friday\n06:30 - 18:00 WIB',
              onTap: null,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            // Message Form
            Text(
              l10n.contactSendMessage,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _subjectController,
                    label: l10n.contactSubject,
                    hint: l10n.contactSubjectHint,
                    prefixIcon: Iconsax.edit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.validationRequired;
                      }
                      return null;
                    },
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 400),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  AppTextField(
                    controller: _messageController,
                    label: l10n.contactMessage,
                    hint: l10n.contactMessageHint,
                    prefixIcon: Iconsax.message_text,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.validationRequired;
                      }
                      return null;
                    },
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 400),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  PrimaryButton(
                    text: l10n.contactSendButton,
                    isLoading: _isLoading,
                    onPressed: _handleSend,
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 400),
                  ),
                ],
              ),
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
