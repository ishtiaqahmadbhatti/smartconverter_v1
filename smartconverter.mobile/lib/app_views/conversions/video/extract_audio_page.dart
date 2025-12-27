import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'video_common_page.dart';

class ExtractAudioPage extends StatefulWidget {
  const ExtractAudioPage({super.key});

  @override
  State<ExtractAudioPage> createState() => _ExtractAudioPageState();
}

class _ExtractAudioPageState extends State<ExtractAudioPage> {
  String _selectedFormat = 'mp3';
  String _selectedBitrate = '192k';
  final List<String> _formats = ['mp3', 'wav', 'aac', 'm4a', 'flac'];
  final List<String> _bitrates = ['128k', '192k', '256k', '320k'];

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Extract Audio',
      inputExtension: 'video',
      outputExtension: _selectedFormat,
      isVariableOutput: true,
      apiEndpoint: ApiConfig.videoExtractAudioEndpoint,
      outputFolder: 'extract-audio',
      extraParamsBuilder: () => {
        'output_format': _selectedFormat,
        'bitrate': _selectedBitrate,
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
                      icon: const Icon(Icons.audiotrack, color: AppColors.primaryBlue),
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
                      value: _selectedBitrate,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundSurface,
                      icon: const Icon(Icons.music_note, color: AppColors.primaryBlue),
                      items: _bitrates.map((bitrate) {
                        return DropdownMenuItem(
                          value: bitrate,
                          child: Text(
                            bitrate,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedBitrate = value);
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
