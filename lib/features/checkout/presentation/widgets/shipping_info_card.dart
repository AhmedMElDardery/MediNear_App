import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import '../screens/checkout_screen.dart'; // To access checkoutProvider

class ShippingInfoCard extends ConsumerStatefulWidget {
  const ShippingInfoCard({super.key});

  @override
  ConsumerState<ShippingInfoCard> createState() => _ShippingInfoCardState();
}

class _ShippingInfoCardState extends ConsumerState<ShippingInfoCard> {
  // 1. ليستة الدول بنفس الفكرة
  final List<Map<String, dynamic>> countries = [
    {'name': 'Egypt', 'flag': '��', 'code': '+20', 'maxLength': 11},
    {'name': 'Saudi Arabia', 'flag': '��', 'code': '+966', 'maxLength': 9},
    {'name': 'UAE', 'flag': '��', 'code': '+971', 'maxLength': 9},
    {'name': 'Kuwait', 'flag': '��', 'code': '+965', 'maxLength': 8},
  ];

  late Map<String, dynamic> selectedCountry;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = countries[0]; // الديفولت مصر
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primary = Theme.of(context).colorScheme.primary;
    final provider = ref.read(checkoutProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: primary),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate("shippingInformation"),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            children: [
              _buildModernTextField(
                label: AppLocalizations.of(context)!.translate("fullName"),
                icon: Icons.person_outline,
                controller: provider.nameController,
                context: context,
              ),
              const SizedBox(height: 16),
              _buildModernPhoneField(AppLocalizations.of(context)!.translate("phoneNumber"), provider.phoneController, context),
              const SizedBox(height: 16),
              _buildModernTextField(
                label: AppLocalizations.of(context)!.translate("fullAddress"),
                icon: Icons.location_on_outlined,
                controller: provider.addressController,
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Premium Phone Field ---
  Widget _buildModernPhoneField(String label, TextEditingController controller, BuildContext context) {
    final fillColor = Theme.of(context).scaffoldBackgroundColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedCountry,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    items: countries.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c['flag']} ${c['code']}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCountry = val!;
                        controller.clear();
                      });
                    },
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey.withValues(alpha: 0.3)),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(selectedCountry['maxLength']),
                  ],
                  decoration: InputDecoration(
                    hintText: selectedCountry['code'] == '+20' ? "1xxxxxxxxx" : "",
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Premium Normal Text Field ---
  Widget _buildModernTextField({required String label, required IconData icon, required TextEditingController controller, required BuildContext context}) {
    final fillColor = Theme.of(context).scaffoldBackgroundColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}