import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToJpgImagePage extends StatelessWidget {
  const PdfToJpgImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert PDF to JPG',
    categoryIcon: Icons.image_outlined,
  );
}
