
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'file_formatter_common_page.dart';

class XmlFormatterPage extends StatefulWidget {
  const XmlFormatterPage({super.key});

  @override
  State<XmlFormatterPage> createState() => _XmlFormatterPageState();
}

class _XmlFormatterPageState extends State<XmlFormatterPage> {
  int _indent = 2;

  @override
  Widget build(BuildContext context) {
    return FileFormatterCommonPage(
      toolName: 'Format XML',
      inputExtension: 'xml',
      outputExtension: 'xml',
      apiEndpoint: ApiConfig.fileFormatXmlEndpoint,
      outputFolder: 'formatted_xml',
      extraParamsBuilder: () => {
        'indent': _indent.toString(),
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
        ];
      },
    );
  }
}
