import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Menu card widget for dashboard items.
class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final int index;
  final bool compact;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.index = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = compact ? AppDimensions.radiusM : AppDimensions.radiusL;
    final cardPadding = compact
        ? const EdgeInsets.all(AppDimensions.paddingS)
        : const EdgeInsets.all(AppDimensions.paddingM);
    final iconPadding = compact
        ? const EdgeInsets.all(AppDimensions.paddingS)
        : const EdgeInsets.all(AppDimensions.paddingM);
    final iconSize = compact ? AppDimensions.iconM : AppDimensions.iconL;
    final iconSlotSize = compact ? 40.0 : 64.0;
    final titleFontSize = compact ? 12.0 : 14.0;
    final titleWeight = compact ? FontWeight.w500 : FontWeight.w600;
    final titleSlotHeight = compact ? 32.0 : 54.0;

    return Card(
          elevation: AppDimensions.elevationS,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(cardRadius),
            child: Container(
              padding: cardPadding,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.cardBackground,
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSlotSize,
                    height: iconSlotSize,
                    child: Center(
                      child: Container(
                        padding: iconPadding,
                        decoration: BoxDecoration(
                          color: (iconColor ?? AppColors.primary).withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: iconSize,
                          color: iconColor ?? AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: compact
                        ? AppDimensions.paddingS
                        : AppDimensions.paddingM,
                  ),
                  SizedBox(
                    height: titleSlotHeight,
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: titleFontSize,
                          fontWeight: titleWeight,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }
}

/// List menu item card for settings and other lists.
class MenuListItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final bool showArrow;

  const MenuListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconM,
            color: iconColor ?? AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing:
            trailing ??
            (showArrow
                ? const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  )
                : null),
      ),
    );
  }
}
