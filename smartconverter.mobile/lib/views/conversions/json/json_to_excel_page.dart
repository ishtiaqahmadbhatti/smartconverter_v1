import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonToExcelPage extends StatelessWidget {
  const JsonToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert JSON to Excel',
    categoryIcon: Icons.data_object,
  );
}
