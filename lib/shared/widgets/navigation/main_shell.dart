import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:saintjohn_sms_mobile/core/localization/generated/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../routing/app_router.dart';

/// Main shell widget with bottom navigation.
class MainShell extends StatefulWidget {
  final Widget child;
  final UserType userType;

  const MainShell({super.key, required this.child, required this.userType});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Iconsax.home,
                  activeIcon: Iconsax.home_15,
                  label: l10n.dashboardTitle,
                  index: 0,
                  onTap: () => _onItemTapped(0, context),
                ),
                _buildNavItem(
                  icon: Iconsax.setting_2,
                  activeIcon: Iconsax.setting,
                  label: l10n.settingsTitle,
                  index: 1,
                  onTap: () => _onItemTapped(1, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    if (widget.userType == UserType.parent) {
      if (index == 0) {
        context.go(AppRoutes.parentDashboard);
      } else {
        context.go(AppRoutes.parentSettings);
      }
    } else {
      if (index == 0) {
        context.go(AppRoutes.studentDashboard);
      } else {
        context.go(AppRoutes.studentSettings);
      }
    }
  }
}
