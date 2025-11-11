import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class Mp4ToMp3Page extends StatelessWidget {
  const Mp4ToMp3Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Convert MP4 to MP3',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
