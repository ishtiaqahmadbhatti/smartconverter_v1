import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToJsonFromJsonCategoryPage extends StatelessWidget {
  const CsvToJsonFromJsonCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert CSV to JSON',
    categoryIcon: Icons.data_object,
  );
}
