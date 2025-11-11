import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MarkdownToHtmlPage extends StatelessWidget {
  const MarkdownToHtmlPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Markdown To HTML',
    categoryIcon: Icons.text_fields,
  );
}
