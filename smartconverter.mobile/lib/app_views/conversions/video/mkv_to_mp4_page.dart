import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'video_common_page.dart';

class MkvToMp4Page extends StatelessWidget {
  const MkvToMp4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoCommonPage(
      toolName: 'Convert MKV to MP4',
      inputExtension: 'mkv',
      outputExtension: 'mp4',
      apiEndpoint: ApiConfig.videoMkvToMp4Endpoint,
      outputFolder: 'mkv-to-mp4',
    );
  }
}
