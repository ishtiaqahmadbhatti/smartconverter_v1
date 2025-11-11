import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoToAudioPage extends StatelessWidget {
  const VideoToAudioPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Video To Audio',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
