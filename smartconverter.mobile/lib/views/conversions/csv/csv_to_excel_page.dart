import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToExcelPage extends StatelessWidget {
  const CsvToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To Excel',
    categoryIcon: Icons.table_chart_outlined,
  );
}
