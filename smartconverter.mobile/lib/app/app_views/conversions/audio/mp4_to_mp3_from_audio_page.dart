
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'audio_common_page.dart';

class Mp4ToMp3FromAudioPage extends StatelessWidget {
  const Mp4ToMp3FromAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudioCommonPage(
      toolName: 'Convert MP4 to MP3',
      inputExtension: 'video', // Allow MP4 selection
      outputExtension: 'mp3',
      apiEndpoint: ApiConfig.audioMp4ToMp3Endpoint,
      outputFolder: 'mp4-to-mp3',
      extraWidgetsBuilder: (context, setState) {
        // We could reuse the dropdowns from the video version if we want bitrate control
        return [
           // Defaulting to 192k bitrate for simplicity in this quick implementation,
           // or we can add the dropdown. Let's add simple bitrate dropdown.
        ];
      },
      extraParamsBuilder: () => {
        'bitrate': '192k',
        'quality': 'medium',
      },
    );
  }
}
