import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OdsToCsvPage extends StatelessWidget {
  const OdsToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert OpenOffice Calc ODS to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
