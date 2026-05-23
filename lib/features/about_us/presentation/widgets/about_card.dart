import 'package:flutter/material.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle,
                  color: theme.colorScheme.primary, size: 36),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.translate("aboutTitle"),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 14,
                  height: 1.5),
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.translate("aboutDescriptionPrefix"),
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.translate("aboutDescription"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}