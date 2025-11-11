import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MarkdownToPdfPage extends StatelessWidget {
  const MarkdownToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'Convert Markdown to PDF',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
