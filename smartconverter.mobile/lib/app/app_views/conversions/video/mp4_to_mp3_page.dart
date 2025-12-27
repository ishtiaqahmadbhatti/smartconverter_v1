import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'video_common_page.dart';

class Mp4ToMp3Page extends StatefulWidget {
  const Mp4ToMp3Page({super.key});

  @override
  State<Mp4ToMp3Page> createState() => _Mp4ToMp3PageState();
}

class _Mp4ToMp3PageState extends State<Mp4ToMp3Page> {
  String _selectedBitrate = '192k';
  final List<String> _bitrates = ['128k', '192k', '256k', '320k'];

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Convert MP4 to MP3',
      inputExtension: 'mp4',
      outputExtension: 'mp3',
      apiEndpoint: ApiConfig.videoMp4ToMp3Endpoint,
      outputFolder: 'mp4-to-mp3',
      extraParamsBuilder: () => {'bitrate': _selectedBitrate},
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
                value: _selectedBitrate,
                isExpanded: true,
                dropdownColor: AppColors.backgroundSurface,
                icon: const Icon(Icons.music_note, color: AppColors.primaryBlue),
                items: _bitrates.map((bitrate) {
                  return DropdownMenuItem(
                    value: bitrate,
                    child: Text(
                      'Bitrate: $bitrate',
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
        ];
      },
    );
  }
}
