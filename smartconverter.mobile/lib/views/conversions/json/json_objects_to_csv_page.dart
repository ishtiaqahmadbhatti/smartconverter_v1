import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonObjectsToCsvPage extends StatelessWidget {
  const JsonObjectsToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert JSON objects to CSV',
    categoryIcon: Icons.data_object,
  );
}
