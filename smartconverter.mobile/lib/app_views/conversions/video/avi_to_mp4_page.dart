import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'video_common_page.dart';

class AviToMp4Page extends StatelessWidget {
  const AviToMp4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoCommonPage(
      toolName: 'Convert AVI to MP4',
      inputExtension: 'avi',
      outputExtension: 'mp4',
      apiEndpoint: ApiConfig.videoAviToMp4Endpoint,
      outputFolder: 'avi-to-mp4',
    );
  }
}
