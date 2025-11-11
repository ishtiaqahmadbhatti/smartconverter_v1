import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToXlsPage extends StatelessWidget {
  const SrtToXlsPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert SRT to XLS',
    categoryIcon: Icons.subtitles_outlined,
  );
}
