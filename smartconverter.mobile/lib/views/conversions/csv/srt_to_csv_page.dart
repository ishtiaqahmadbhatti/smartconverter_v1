import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToCsvPage extends StatelessWidget {
  const SrtToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert SRT to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
