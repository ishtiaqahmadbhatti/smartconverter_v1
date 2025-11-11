import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class BsonToCsvPage extends StatelessWidget {
  const BsonToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'Convert BSON to CSV',
    categoryIcon: Icons.table_chart_outlined,
  );
}
