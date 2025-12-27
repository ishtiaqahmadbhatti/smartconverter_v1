import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoQualityPage extends StatelessWidget {
  const VideoQualityPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Video Quality',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
