import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToVttPage extends StatelessWidget {
  const SrtToVttPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'SRT To VTT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
