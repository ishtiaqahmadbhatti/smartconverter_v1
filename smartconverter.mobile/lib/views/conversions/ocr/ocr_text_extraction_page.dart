import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrTextExtractionPage extends StatelessWidget {
  const OcrTextExtractionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR Text Extraction',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
