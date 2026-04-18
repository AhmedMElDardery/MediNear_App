import 'package:flutter/material.dart';
// ✅ تعديل المسار ليكون صحيحاً (نخرج خطوة للمجلد الأب ثم ندخل core/theme)

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // ✅ استخدام اللون الأساسي من الثيم أو من ملف AppColors الجديد
        backgroundColor: Theme.of(context).primaryColor, 
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      // تحسين طريقة عرض الأيقونة
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}