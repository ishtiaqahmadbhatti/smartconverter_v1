import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToXpsPage extends StatelessWidget {
  const ExcelToXpsPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'Convert Excel to XPS',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
