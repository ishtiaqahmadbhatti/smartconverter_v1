import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToCsvPage extends StatelessWidget {
  const PdfToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert PDF to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
