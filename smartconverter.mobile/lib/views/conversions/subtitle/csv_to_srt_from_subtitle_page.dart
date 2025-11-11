import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToSrtFromSubtitlePage extends StatelessWidget {
  const CsvToSrtFromSubtitlePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert CSV to SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
