import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageToTextPage extends StatelessWidget {
  const ImageToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ocr_conversion',
    toolName: 'Image To Text',
    categoryIcon: Icons.document_scanner_outlined,
  );
}
