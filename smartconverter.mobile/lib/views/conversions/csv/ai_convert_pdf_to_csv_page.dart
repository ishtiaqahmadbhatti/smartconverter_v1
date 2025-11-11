import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiConvertPdfToCsvPage extends StatelessWidget {
  const AiConvertPdfToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'AI: Convert PDF to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
