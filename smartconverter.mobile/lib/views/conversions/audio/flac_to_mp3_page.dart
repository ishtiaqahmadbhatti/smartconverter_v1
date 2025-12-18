
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'audio_common_page.dart';

class FlacToMp3Page extends StatelessWidget {
  const FlacToMp3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCommonPage(
      toolName: 'Convert FLAC to MP3',
      inputExtension: 'flac',
      outputExtension: 'mp3',
      apiEndpoint: ApiConfig.audioFlacToMp3Endpoint,
      outputFolder: 'flac-to-mp3',
    );
  }
}
