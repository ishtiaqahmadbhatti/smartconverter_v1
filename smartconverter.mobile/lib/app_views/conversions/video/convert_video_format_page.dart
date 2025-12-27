import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'video_common_page.dart';

class ConvertVideoFormatPage extends StatefulWidget {
  const ConvertVideoFormatPage({super.key});

  @override
  State<ConvertVideoFormatPage> createState() => _ConvertVideoFormatPageState();
}

class _ConvertVideoFormatPageState extends State<ConvertVideoFormatPage> {
  String _selectedFormat = 'mp4';
  String _selectedQuality = 'medium';
  final List<String> _formats = [
    'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'
  ];
  final List<String> _qualities = ['low', 'medium', 'high', 'ultra'];

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Convert Video Format',
      inputExtension: 'video', // Generic video input
      outputExtension: _selectedFormat,
      isVariableOutput: true,
      apiEndpoint: ApiConfig.videoConvertFormatEndpoint,
      outputFolder: 'convert-video-format',
      extraParamsBuilder: () => {
        'output_format': _selectedFormat,
        'quality': _selectedQuality,
      },
      extraWidgetsBuilder: (context, setState) {
        return [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      icon: const Icon(Icons.movie_creation, color: AppColors.primaryBlue),
                      items: _formats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(
                            format.toUpperCase(),
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedFormat = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedQuality,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundSurface,
                      icon: const Icon(Icons.high_quality, color: AppColors.primaryBlue),
                      items: _qualities.map((quality) {
                        return DropdownMenuItem(
                          value: quality,
                          child: Text(
                            quality[0].toUpperCase() + quality.substring(1),
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedQuality = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];
      },
    );
  }
}
