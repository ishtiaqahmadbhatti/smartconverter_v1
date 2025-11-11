import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToTextTextPage extends StatelessWidget {
  const PdfToTextTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Convert PDF to Text',
    categoryIcon: Icons.text_fields,
  );
}
