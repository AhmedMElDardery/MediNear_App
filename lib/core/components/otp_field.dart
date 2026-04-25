import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

class OTPField extends ConsumerStatefulWidget {
  final Function(String) onComplete;
  const OTPField({super.key, required this.onComplete});

  @override
  ConsumerState<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends ConsumerState<OTPField> {
  final List<TextEditingController> controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    }
    if (index == 3) {
      final otp = controllers.map((c) => c.text).join();
      widget.onComplete(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        ),
      ),
    );
  }
}
