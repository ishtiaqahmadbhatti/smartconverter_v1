import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrJpgToPdfPage extends StatelessWidget {
  const OcrJpgToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR: Convert JPG to PDF',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
