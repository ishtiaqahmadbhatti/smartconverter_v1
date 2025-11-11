import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToXlsxPage extends StatelessWidget {
  const SrtToXlsxPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert SRT to XLSX',
    categoryIcon: Icons.subtitles_outlined,
  );
}
