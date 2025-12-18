
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'audio_common_page.dart';

class TrimAudioPage extends StatefulWidget {
  const TrimAudioPage({super.key});

  @override
  State<TrimAudioPage> createState() => _TrimAudioPageState();
}

class _TrimAudioPageState extends State<TrimAudioPage> {
  final TextEditingController _startController = TextEditingController(text: '0.0');
  final TextEditingController _endController = TextEditingController(text: '10.0');

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudioCommonPage(
      toolName: 'Trim Audio',
      inputExtension: 'audio',
      outputExtension: 'wav',
      apiEndpoint: ApiConfig.audioTrimEndpoint,
      outputFolder: 'trim-audio',
      extraWidgetsBuilder: (context, setStateSource) {
        return [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Start Time (sec)',
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _endController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'End Time (sec)',
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ];
      },
      extraParamsBuilder: () => {
        'start_time': _startController.text,
        'end_time': _endController.text,
      },
    );
  }
}
