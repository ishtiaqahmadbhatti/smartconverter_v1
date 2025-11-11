import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToJsonPage extends StatelessWidget {
  const CsvToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To JSON',
    categoryIcon: Icons.table_chart_outlined,
  );
}
