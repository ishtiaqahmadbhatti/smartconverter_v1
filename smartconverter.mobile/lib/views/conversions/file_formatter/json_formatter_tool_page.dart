import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonFormatterToolPage extends StatelessWidget {
  const JsonFormatterToolPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'JSON Formatter',
    categoryIcon: Icons.format_align_left,
  );
}
