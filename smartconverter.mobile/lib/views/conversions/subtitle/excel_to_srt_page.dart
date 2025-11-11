import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToSrtPage extends StatelessWidget {
  const ExcelToSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert Excel to SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
