import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonToCsvFromCsvCategoryPage extends StatelessWidget {
  const JsonToCsvFromCsvCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert JSON to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
