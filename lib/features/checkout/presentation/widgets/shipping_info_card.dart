import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medinear_app/core/theme/app_colors.dart';

class ShippingInfoCard extends StatefulWidget {
  const ShippingInfoCard({super.key});

  @override
  State<ShippingInfoCard> createState() => _ShippingInfoCardState();
}

class _ShippingInfoCardState extends State<ShippingInfoCard> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shipping Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            children: [
              // خانة الاسم العادية
              _buildNormalTextField("Full Name", isDark),
              const Divider(height: 15, thickness: 0.5),
              
              // 🚀 خانة التليفون الاحترافية (كود الدولة + الرقم)
              _buildPhoneField("Phone Number", isDark),
              
              const Divider(height: 15, thickness: 0.5),
              // خانة العنوان العادية
              _buildNormalTextField("Full Address", isDark, icon: Icons.map_outlined),
            ],
          ),
        ),
      ],
    );
  }

  // --- دالة رسم خانة التليفون الجديدة ---
  Widget _buildPhoneField(String label, bool isDark) {
    return Row(
      children: [
        // 1. اسم الخانة (Phone Number)
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        // 2. الجزء الخاص بالرقم وكود الدولة
        Expanded(
          child: Row(
            children: [
              // أ. Dropdown كود الدولة
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedCountry,
                    icon: const Icon(Icons.arrow_drop_down, size: 14),
                    items: countries.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c['flag']} ${c['code']}', style: const TextStyle(fontSize: 11)), // صغرنا الخط سيكا عشان المساحة
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCountry = val!;
                        _phoneController.clear(); // نمسح الرقم لو غير الدولة
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              
              // ب. خانة إدخال الرقم
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(selectedCountry['maxLength']),
                    ],
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: selectedCountry['code'] == '+20' ? "1xxxxxxxxx" : "",
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
  Widget _buildNormalTextField(String label, bool isDark, {IconData? icon}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                suffixIcon: icon != null ? Icon(icon, size: 16, color: Colors.black87) : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 35, minHeight: 20),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}