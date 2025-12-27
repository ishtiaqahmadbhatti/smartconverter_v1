
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'audio_common_page.dart';

class Mp3ToWavPage extends StatelessWidget {
  const Mp3ToWavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCommonPage(
      toolName: 'Convert MP3 to WAV',
      inputExtension: 'mp3',
      outputExtension: 'wav',
      apiEndpoint: ApiConfig.audioMp3ToWavEndpoint,
      outputFolder: 'mp3-to-wav',
    );
  }
}
