import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvValidationPage extends StatelessWidget {
  const CsvValidationPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV Validation',
    categoryIcon: Icons.table_chart_outlined,
  );
}
