import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OcrPngToTextPage extends StatelessWidget {
  const OcrPngToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'OCR: Convert PNG to Text',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
