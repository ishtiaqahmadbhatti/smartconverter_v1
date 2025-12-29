import '../app_modules/imports_module.dart';

class ConversionFileNameFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String extensionLabel;
  final String? suggestedName;

  const ConversionFileNameFieldWidget({
    super.key,
    required this.controller,
    this.hintText = 'converted_document',
    this.labelText = 'Output file name',
    this.extensionLabel = '.txt extension is added automatically',
    this.suggestedName,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: suggestedName ?? hintText,
        prefixIcon: const Icon(Icons.edit_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        helperText: extensionLabel,
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }
}
