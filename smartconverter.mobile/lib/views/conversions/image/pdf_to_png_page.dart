import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToPngImagePage extends StatelessWidget {
  const PdfToPngImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert PDF to PNG',
    categoryIcon: Icons.image_outlined,
  );
}
