import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiPdfToExcelPage extends StatelessWidget {
  const AiPdfToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'AI: Convert PDF to Excel',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
