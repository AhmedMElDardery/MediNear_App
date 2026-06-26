import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import '../manager/checkout_provider.dart';
import '../screens/checkout_screen.dart'; // To access checkoutProvider

class PaymentMethodCard extends ConsumerWidget {
  const PaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(checkoutProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payment_outlined, color: primary),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate("paymentMethod"),
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: primary),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                context: context,
                title: "Cash",
                value: 'cash',
                icon: Icons.money,
                provider: provider,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildSelectableCard(
                context: context,
                title: "Paymob",
                value: 'paymob',
                icon: Icons.credit_card,
                provider: provider,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required CheckoutProvider provider,
  }) {
    final isSelected = provider.paymentMethod == value;
    final primary = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: () => provider.setPaymentMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.1) : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primary : Colors.grey, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primary : textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
