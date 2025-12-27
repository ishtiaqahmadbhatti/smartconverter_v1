import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvFormatterToolPage extends StatelessWidget {
  const CsvFormatterToolPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'CSV Formatter',
    categoryIcon: Icons.format_align_left,
  );
}
