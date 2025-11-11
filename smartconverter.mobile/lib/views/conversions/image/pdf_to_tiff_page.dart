import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToTiffImagePage extends StatelessWidget {
  const PdfToTiffImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert PDF to TIFF',
    categoryIcon: Icons.image_outlined,
  );
}
