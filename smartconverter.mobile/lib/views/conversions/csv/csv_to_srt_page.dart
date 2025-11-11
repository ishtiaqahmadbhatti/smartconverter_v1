import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToSrtPage extends StatelessWidget {
  const CsvToSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert CSV to SRT',
    categoryIcon: Icons.table_chart_outlined,
  );
}
