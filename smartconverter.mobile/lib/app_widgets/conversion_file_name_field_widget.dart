import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConversionFileNameFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;

  const ConversionFileNameFieldWidget({
    super.key,
    required this.controller,
    this.hintText = 'converted_document',
    this.labelText = 'Output file name',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.edit_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        helperText: '.txt extension is added automatically',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }
}
