import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoCompressPage extends StatelessWidget {
  const VideoCompressPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Video Compress',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
