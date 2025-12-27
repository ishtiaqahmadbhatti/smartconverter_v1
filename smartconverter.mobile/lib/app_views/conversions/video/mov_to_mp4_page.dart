import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'video_common_page.dart';

class MovToMp4Page extends StatelessWidget {
  const MovToMp4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoCommonPage(
      toolName: 'Convert MOV to MP4',
      inputExtension: 'mov',
      outputExtension: 'mp4',
      apiEndpoint: ApiConfig.videoMovToMp4Endpoint,
      outputFolder: 'mov-to-mp4',
    );
  }
}
