import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToTextPage extends StatelessWidget {
  const SrtToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert SRT to Text',
    categoryIcon: Icons.subtitles_outlined,
  );
}
