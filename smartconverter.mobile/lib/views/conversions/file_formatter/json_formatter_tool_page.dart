
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'file_formatter_common_page.dart';

class JsonFormatterToolPage extends StatefulWidget {
  const JsonFormatterToolPage({super.key});

  @override
  State<JsonFormatterToolPage> createState() => _JsonFormatterToolPageState();
}

class _JsonFormatterToolPageState extends State<JsonFormatterToolPage> {
  int _indent = 2;
  bool _sortKeys = false;

  @override
  Widget build(BuildContext context) {
    return FileFormatterCommonPage(
      toolName: 'Format JSON',
      inputExtension: 'json',
      outputExtension: 'json',
      apiEndpoint: ApiConfig.fileFormatJsonEndpoint,
      outputFolder: 'formatted_json',
      extraParamsBuilder: () => {
        'indent': _indent.toString(),
        'sort_keys': _sortKeys.toString(),
      },
      extraWidgetsBuilder: (context, setStateInternal) {
        return [
          // Indent Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_indent_increase, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Indentation Level',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  ),
                ),
                DropdownButton<int>(
                  value: _indent,
                  dropdownColor: AppColors.backgroundSurface,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: [2, 4, 8].map((e) => DropdownMenuItem(
                    value: e,
                    child: Text('$e spaces'),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setStateInternal(() => _indent = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sort Keys Checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: CheckboxListTile(
              title: const Text('Sort Keys', style: TextStyle(color: AppColors.textPrimary)),
              value: _sortKeys,
              activeColor: AppColors.primaryBlue,
              checkColor: AppColors.textPrimary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              onChanged: (val) {
                if (val != null) setStateInternal(() => _sortKeys = val);
              },
            ),
          ),
        ];
      },
    );
  }
}
