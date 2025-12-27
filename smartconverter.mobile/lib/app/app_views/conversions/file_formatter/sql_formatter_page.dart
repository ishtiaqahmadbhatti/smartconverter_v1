import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SqlFormatterPage extends StatelessWidget {
  const SqlFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'SQL Formatter',
    categoryIcon: Icons.format_align_left,
  );
}
