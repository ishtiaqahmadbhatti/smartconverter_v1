import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OxpsToPdfPage extends StatelessWidget {
  const OxpsToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'Convert OXPS to PDF',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
