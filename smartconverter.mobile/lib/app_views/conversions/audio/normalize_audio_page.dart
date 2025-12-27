
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';
import 'audio_common_page.dart';

class NormalizeAudioPage extends StatefulWidget {
  const NormalizeAudioPage({super.key});

  @override
  State<NormalizeAudioPage> createState() => _NormalizeAudioPageState();
}

class _NormalizeAudioPageState extends State<NormalizeAudioPage> {
  double _targetDb = -20.0;

  @override
  Widget build(BuildContext context) {
    return AudioCommonPage(
      toolName: 'Normalize Audio',
      inputExtension: 'audio',
      outputExtension: 'wav',
      apiEndpoint: ApiConfig.audioNormalizeEndpoint,
      outputFolder: 'normalize-audio',
      extraWidgetsBuilder: (context, setStateSource) {
        return [
           const Text(
            'Target Level (dBFS)',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _targetDb,
            min: -50.0,
            max: 0.0,
            divisions: 50,
            label: '${_targetDb.toStringAsFixed(1)} dB',
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.backgroundSurface,
            onChanged: (val) {
              setStateSource(() => _targetDb = val);
            },
          ),
          Text(
            'Selected level: ${_targetDb.toStringAsFixed(1)} dB',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ];
      },
      extraParamsBuilder: () => {
        'target_dBFS': _targetDb.toString(),
      },
    );
  }
}
