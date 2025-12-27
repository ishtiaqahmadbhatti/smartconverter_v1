import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'video_common_page.dart';

class CompressVideoPage extends StatefulWidget {
  const CompressVideoPage({super.key});

  @override
  State<CompressVideoPage> createState() => _CompressVideoPageState();
}

class _CompressVideoPageState extends State<CompressVideoPage> {
  String _selectedLevel = 'medium';
  final List<String> _levels = ['low', 'medium', 'high', 'ultra'];

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Compress Video',
      inputExtension: 'video',
      outputExtension: 'mp4',
      apiEndpoint: ApiConfig.videoCompressEndpoint,
      outputFolder: 'compress-video',
      extraParamsBuilder: () => {'compression_level': _selectedLevel},
      extraWidgetsBuilder: (context, setState) {
        return [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLevel,
                isExpanded: true,
                dropdownColor: AppColors.backgroundSurface,
                icon: const Icon(Icons.compress, color: AppColors.primaryBlue),
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      'Compression: ${level[0].toUpperCase() + level.substring(1)}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLevel = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Higher compression means smaller file size but lower quality.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ];
      },
    );
  }
}
