import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'video_common_page.dart';

class ResizeVideoPage extends StatefulWidget {
  const ResizeVideoPage({super.key});

  @override
  State<ResizeVideoPage> createState() => _ResizeVideoPageState();
}

class _ResizeVideoPageState extends State<ResizeVideoPage> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedQuality = 'medium';
  final List<String> _qualities = ['low', 'medium', 'high', 'ultra'];

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoCommonPage(
      toolName: 'Resize Video',
      inputExtension: 'video',
      outputExtension: 'mp4', // Usually outputs MP4
      apiEndpoint: ApiConfig.videoResizeEndpoint,
      outputFolder: 'resize-video',
      extraParamsBuilder: () => {
        'width': _widthController.text.trim(),
        'height': _heightController.text.trim(),
        'quality': _selectedQuality,
      },
      extraWidgetsBuilder: (context, setState) {
        return [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Width (px)',
                    hintText: 'e.g. 1280',
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.horizontal_rule),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (px)',
                    hintText: 'e.g. 720',
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.vertical_align_center),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
                      'Quality: ${quality[0].toUpperCase() + quality.substring(1)}',
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
        ];
      },
    );
  }
}
