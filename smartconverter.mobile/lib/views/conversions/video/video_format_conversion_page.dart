import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VideoFormatConversionPage extends StatelessWidget {
  const VideoFormatConversionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Video Format Conversion',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
