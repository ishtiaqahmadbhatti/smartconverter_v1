
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'audio_common_page.dart';

class WavToFlacPage extends StatelessWidget {
  const WavToFlacPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCommonPage(
      toolName: 'Convert WAV to FLAC',
      inputExtension: 'wav',
      outputExtension: 'flac',
      apiEndpoint: ApiConfig.audioWavToFlacEndpoint,
      outputFolder: 'wav-to-flac',
    );
  }
}
