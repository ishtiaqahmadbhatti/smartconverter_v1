import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ScannedPdfToTextPage extends StatelessWidget {
  const ScannedPdfToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'Scanned PDF To Text',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
