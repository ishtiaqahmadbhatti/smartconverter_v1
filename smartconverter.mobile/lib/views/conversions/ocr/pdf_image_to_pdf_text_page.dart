import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrPdfImageToPdfTextPage extends StatelessWidget {
  const OcrPdfImageToPdfTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR: Convert PDF Image to PDF Text',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
