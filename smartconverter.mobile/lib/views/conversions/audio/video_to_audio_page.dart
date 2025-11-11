import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoToAudioAudioPage extends StatelessWidget {
  const VideoToAudioAudioPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Video To Audio',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
