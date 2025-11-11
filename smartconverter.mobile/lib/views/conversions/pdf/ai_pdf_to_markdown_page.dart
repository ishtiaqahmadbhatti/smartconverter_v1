import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiPdfToMarkdownPage extends StatelessWidget {
  const AiPdfToMarkdownPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'AI: Convert PDF to Markdown',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
