import 'package:flutter/material.dart';

class PremiumProfileGroup extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const PremiumProfileGroup({
    super.key,
    required this.children,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isDark
                    ? theme.dividerColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 64,
                    color: isDark
                        ? theme.dividerColor.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PremiumProfileTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const PremiumProfileTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDestructive
                          ? Colors.red.withValues(alpha: 0.1)
                          : iconColor.withValues(alpha: 0.1)),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? const Color(0xFFEF4444) : iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? const Color(0xFFEF4444)
                            : (isDark
                                ? theme.textTheme.bodyLarge?.color ??
                                    Colors.white
                                : const Color(0xFF1E293B)),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
