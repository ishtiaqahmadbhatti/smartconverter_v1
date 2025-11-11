import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToCsvFromSubtitlePage extends StatelessWidget {
  const SrtToCsvFromSubtitlePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert SRT to CSV',
    categoryIcon: Icons.subtitles_outlined,
  );
}
