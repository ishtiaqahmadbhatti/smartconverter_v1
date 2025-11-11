import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrPngToPdfPage extends StatelessWidget {
  const OcrPngToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR: Convert PNG to PDF',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
