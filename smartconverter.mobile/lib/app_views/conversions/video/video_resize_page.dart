import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoResizePage extends StatelessWidget {
  const VideoResizePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Video Resize',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
