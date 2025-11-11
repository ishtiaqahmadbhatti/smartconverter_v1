import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiPdfToJsonPage extends StatelessWidget {
  const AiPdfToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'AI: Convert PDF to JSON',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
