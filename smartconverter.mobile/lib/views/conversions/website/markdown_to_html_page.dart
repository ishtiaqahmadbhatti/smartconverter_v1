import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MarkdownToHtmlWebPage extends StatelessWidget {
  const MarkdownToHtmlWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert Markdown to HTML',
    categoryIcon: Icons.public_outlined,
  );
}
