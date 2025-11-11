import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvFormatterPage extends StatelessWidget {
  const CsvFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV Formatter',
    categoryIcon: Icons.table_chart_outlined,
  );
}
