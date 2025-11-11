import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToHtmlWebPage extends StatelessWidget {
  const PdfToHtmlWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert PDF to HTML',
    categoryIcon: Icons.public_outlined,
  );
}
