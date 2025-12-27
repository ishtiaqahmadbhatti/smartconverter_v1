import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CodeFormatterPage extends StatelessWidget {
  const CodeFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'Code Formatter',
    categoryIcon: Icons.format_align_left,
  );
}
