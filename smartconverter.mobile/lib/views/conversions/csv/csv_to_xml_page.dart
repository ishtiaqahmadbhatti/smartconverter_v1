import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToXmlPage extends StatelessWidget {
  const CsvToXmlPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To XML',
    categoryIcon: Icons.table_chart_outlined,
  );
}
