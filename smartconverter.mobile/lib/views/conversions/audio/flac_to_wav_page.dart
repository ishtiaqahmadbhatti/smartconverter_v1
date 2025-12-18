
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'audio_common_page.dart';

class FlacToWavPage extends StatelessWidget {
  const FlacToWavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCommonPage(
      toolName: 'Convert FLAC to WAV',
      inputExtension: 'flac',
      outputExtension: 'wav',
      apiEndpoint: ApiConfig.audioFlacToWavEndpoint,
      outputFolder: 'flac-to-wav',
    );
  }
}
