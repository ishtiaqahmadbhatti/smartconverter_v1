import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonObjectsToCsvFromCsvCategoryPage extends StatelessWidget {
  const JsonObjectsToCsvFromCsvCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert JSON objects to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
