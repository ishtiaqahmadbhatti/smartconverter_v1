import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToSvgImagePage extends StatelessWidget {
  const PdfToSvgImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert PDF to SVG',
    categoryIcon: Icons.image_outlined,
  );
}
