import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrPdfToTextPage extends StatelessWidget {
  const OcrPdfToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR: Convert PDF to Text',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
