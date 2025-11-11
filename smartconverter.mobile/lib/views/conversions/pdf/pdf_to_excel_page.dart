import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToExcelPage extends StatelessWidget {
  const PdfToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'Convert PDF to Excel',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
