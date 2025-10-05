import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeType badgeType;
  final bool isEarned;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.badgeType,
    required this.isEarned,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:  [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.backgroundColor,
              border: Border.all(
                color: isEarned
                    ? AppTheme.primaryColor
                    : AppTheme.dividerColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badgeType.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: isEarned ? null : Colors.grey.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              badgeType.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isEarned ? FontWeight.w600 : FontWeight.normal,
                color: isEarned
                    ? AppTheme.textPrimaryColor
                    : AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeDetailSheet extends StatelessWidget {
  final BadgeType badgeType;
  final bool isEarned;

  const BadgeDetailSheet({
    super.key,
    required this.badgeType,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.backgroundColor,
              border: Border.all(
                color: isEarned
                    ? AppTheme.primaryColor
                    : AppTheme.dividerColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                badgeType.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Badge name
          Text(
            badgeType.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badge description
          Text(
            badgeType.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Point value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${badgeType.pointValue} points',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status
          if (!isEarned)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep contributing to unlock this badge!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
