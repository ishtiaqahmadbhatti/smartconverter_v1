import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlToCsvFromCsvCategoryPage extends StatelessWidget {
  const XmlToCsvFromCsvCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert XML to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
