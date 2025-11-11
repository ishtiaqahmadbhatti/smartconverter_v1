import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToJsonPage extends StatelessWidget {
  const ExcelToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert Excel to JSON',
    categoryIcon: Icons.data_object,
  );
}
