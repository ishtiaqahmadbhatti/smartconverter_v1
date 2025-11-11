import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlTableToCsvPage extends StatelessWidget {
  const HtmlTableToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert HTML Table to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
