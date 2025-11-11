import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XlsxToSrtPage extends StatelessWidget {
  const XlsxToSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert XLSX to SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
