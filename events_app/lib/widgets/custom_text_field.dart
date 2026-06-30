// ============================================================
// custom_text_field.dart - Reusable Input Field Widget
// Place this file at: lib/widgets/custom_text_field.dart
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // Controls password visibility toggle

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          validator: widget.validator,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
            // Prefix icon
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textMedium, size: 20)
                : null,
            // Password toggle icon
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// Dropdown field variant for department selection
class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Please select a department' : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.school_outlined,
                color: AppColors.textMedium, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
      ],
    );
  }
}
