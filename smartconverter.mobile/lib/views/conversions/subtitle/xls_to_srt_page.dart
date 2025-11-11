import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XlsToSrtPage extends StatelessWidget {
  const XlsToSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert XLS to SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
