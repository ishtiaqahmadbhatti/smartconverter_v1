import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SubtitleEditPage extends StatelessWidget {
  const SubtitleEditPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Subtitle Edit',
    categoryIcon: Icons.subtitles_outlined,
  );
}
