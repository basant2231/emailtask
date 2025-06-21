import 'package:emailtask/core/app_text_styles.dart';
import 'package:emailtask/core/colors.dart';
import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.fieldLabel,
            border: InputBorder.none,
            prefixIcon: icon != null 
                ? Icon(icon, color: AppColors.fieldIcon) 
                : null,
            alignLabelWithHint: maxLines > 1,
          ),
          validator: validator,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}