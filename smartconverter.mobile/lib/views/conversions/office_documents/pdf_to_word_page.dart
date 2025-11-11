import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToWordOfficePage extends StatelessWidget {
  const PdfToWordOfficePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'PDF To Word',
    categoryIcon: Icons.description_outlined,
  );
}
