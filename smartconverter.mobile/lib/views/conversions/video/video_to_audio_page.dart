import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'video_common_page.dart';

class VideoToAudioPage extends StatefulWidget {
  const VideoToAudioPage({super.key});

  @override
  State<VideoToAudioPage> createState() => _VideoToAudioPageState();
}

class _VideoToAudioPageState extends State<VideoToAudioPage> {
  String _selectedFormat = 'mp3';
  final List<String> _formats = ['mp3', 'wav', 'aac', 'm4a', 'flac'];

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Video To Audio',
      inputExtension: 'video',
      outputExtension: _selectedFormat,
      isVariableOutput: true,
      apiEndpoint: ApiConfig.videoToAudioEndpointNew,
      outputFolder: 'video-to-audio',
      extraParamsBuilder: () => {'output_format': _selectedFormat},
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
                value: _selectedFormat,
                isExpanded: true,
                dropdownColor: AppColors.backgroundSurface,
                icon: const Icon(Icons.audiotrack, color: AppColors.primaryBlue),
                items: _formats.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(
                      'Format: ${format.toUpperCase()}',
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
        ];
      },
    );
  }
}
