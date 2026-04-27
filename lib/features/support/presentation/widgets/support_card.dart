import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medinear_app/core/localization/translate_helper.dart';
import 'package:medinear_app/features/support/data/models/support_item_model.dart';

class SupportCard extends ConsumerStatefulWidget {
  final SupportItemModel item;
  final int index;

  const SupportCard({super.key, required this.item, this.index = 0});

  @override
  ConsumerState<SupportCard> createState() => _SupportCardState();
}

class _SupportCardState extends ConsumerState<SupportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    bool isEmail = widget.item.title == context.tr("support_email");
    bool isCall = widget.item.title == context.tr("support_call");
    bool isWhatsapp = widget.item.title == context.tr("support_whatsapp");

    Color baseColor;
    if (isEmail) {
      baseColor = theme.colorScheme.primary;
    } else if (isWhatsapp) {
      baseColor = const Color(0xFF10B981); // Keep emerald green for WhatsApp
    } else if (isCall) {
      baseColor = theme.colorScheme.secondary;
    } else {
      baseColor = theme.colorScheme.primary;
    }

    Widget iconWidget;
    if (isWhatsapp) {
      iconWidget =
          FaIcon(FontAwesomeIcons.whatsapp, size: 22, color: baseColor);
    } else {
      IconData iconData = widget.item.icon;
      if (isEmail) {
        iconData = Icons.mail_rounded;
      } else if (isCall) {
        iconData = Icons.phone_rounded;
      }
      iconWidget = Icon(iconData, size: 22, color: baseColor);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.item.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: isDark
                  ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor.withValues(alpha: 0.12),
                    border: Border.all(
                        color: baseColor.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.item.title,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? theme.textTheme.bodyLarge?.color ??
                                      Colors.white
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(widget.item.subtitle,
                          style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.2)),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IgnorePointer(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: baseColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(widget.item.buttonText,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
