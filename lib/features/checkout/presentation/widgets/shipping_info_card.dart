import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShippingInfoCard extends ConsumerStatefulWidget {
  const ShippingInfoCard({super.key});

  @override
  ConsumerState<ShippingInfoCard> createState() => _ShippingInfoCardState();
}

class _ShippingInfoCardState extends ConsumerState<ShippingInfoCard> {
  // 1. ليستة الدول بنفس الفكرة
  final List<Map<String, dynamic>> countries = [
    {'name': 'Egypt', 'flag': '🇪🇬', 'code': '+20', 'maxLength': 11},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': '+966', 'maxLength': 9},
    {'name': 'UAE', 'flag': '🇦🇪', 'code': '+971', 'maxLength': 9},
    {'name': 'Kuwait', 'flag': '🇰🇼', 'code': '+965', 'maxLength': 8},
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Shipping Information",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            children: [
              // خانة الاسم العادية
              _buildNormalTextField("Full Name", context),
              const Divider(height: 15, thickness: 0.5),

              // 🚀 خانة التليفون الاحترافية (كود الدولة + الرقم)
              _buildPhoneField("Phone Number", context),

              const Divider(height: 15, thickness: 0.5),
              // خانة العنوان العادية
              _buildNormalTextField("Full Address", context,
                  icon: Icons.map_outlined),
            ],
          ),
        ),
      ],
    );
  }

  // --- دالة رسم خانة التليفون الجديدة ---
  Widget _buildPhoneField(String label, BuildContext context) {
    final fillColor = Theme.of(context).cardColor;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedCountry,
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    items: countries.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c['flag']} ${c['code']}',
                            style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCountry = val!;
                        _phoneController.clear();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                          selectedCountry['maxLength']),
                    ],
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText:
                          selectedCountry['code'] == '+20' ? "1xxxxxxxxx" : "",
                      hintStyle:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- دالة رسم الخانات العادية (الاسم والعنوان) ---
  Widget _buildNormalTextField(String label, BuildContext context, {IconData? icon}) {
    final fillColor = Theme.of(context).cardColor;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                suffixIcon: icon != null
                    ? Icon(icon, size: 16, color: Colors.black87)
                    : null,
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 35, minHeight: 20),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}