import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonObjectsToExcelPage extends StatelessWidget {
  const JsonObjectsToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert JSON objects to Excel',
    categoryIcon: Icons.data_object,
  );
}
