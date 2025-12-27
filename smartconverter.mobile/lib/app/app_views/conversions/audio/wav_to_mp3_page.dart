
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'audio_common_page.dart';

class WavToMp3Page extends StatelessWidget {
  const WavToMp3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCommonPage(
      toolName: 'Convert WAV to MP3',
      inputExtension: 'wav',
      outputExtension: 'mp3',
      apiEndpoint: ApiConfig.audioWavToMp3Endpoint,
      outputFolder: 'wav-to-mp3',
    );
  }
}
