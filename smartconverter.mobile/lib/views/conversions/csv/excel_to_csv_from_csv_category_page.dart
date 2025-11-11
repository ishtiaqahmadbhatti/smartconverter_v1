import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToCsvFromCsvCategoryPage extends StatelessWidget {
  const ExcelToCsvFromCsvCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert Excel to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
