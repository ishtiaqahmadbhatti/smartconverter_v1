import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToExcelPage extends StatelessWidget {
  const SrtToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert SRT to Excel',
    categoryIcon: Icons.subtitles_outlined,
  );
}
