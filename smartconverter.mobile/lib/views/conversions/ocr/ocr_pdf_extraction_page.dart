import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrPdfExtractionPage extends StatelessWidget {
  const OcrPdfExtractionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR PDF Extraction',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
