import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlToMarkdownPage extends StatelessWidget {
  const HtmlToMarkdownPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'HTML To Markdown',
    categoryIcon: Icons.text_fields,
  );
}
