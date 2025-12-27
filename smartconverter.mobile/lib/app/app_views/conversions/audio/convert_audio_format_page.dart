
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'audio_common_page.dart';

class ConvertAudioFormatPage extends StatefulWidget {
  const ConvertAudioFormatPage({super.key});

  @override
  State<ConvertAudioFormatPage> createState() => _ConvertAudioFormatPageState();
}

class _ConvertAudioFormatPageState extends State<ConvertAudioFormatPage> {
  String _selectedFormat = 'mp3';
  final List<String> _formats = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'];

  @override
  Widget build(BuildContext context) {
    return AudioCommonPage(
      toolName: 'Convert Audio Format',
      inputExtension: 'audio',
      outputExtension: _selectedFormat,
      apiEndpoint: ApiConfig.audioConvertFormatEndpoint,
      outputFolder: 'convert-audio-format',
      isVariableOutput: true,
      extraWidgetsBuilder: (context, setStateSource) {
        return [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFormat,
                isExpanded: true,
                dropdownColor: AppColors.backgroundSurface,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                items: _formats.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(
                      'Convert to ${format.toUpperCase()}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setStateSource(() {
                      _selectedFormat = newValue;
                    });
                     // Also update parent state to reflect extension change if needed
                     // But AudioCommonPage reads outputExtension from widget, which is final.
                     // However, for variable output, the tool might rely on the 'output_format' param.
                  }
                },
              ),
            ),
          ),
        ];
      },
      extraParamsBuilder: () => {
        'output_format': _selectedFormat,
        'quality': 'medium', // Default quality
      },
    );
  }
}
