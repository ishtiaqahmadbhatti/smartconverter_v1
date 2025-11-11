import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonToCsvPage extends StatelessWidget {
  const JsonToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'JSON To CSV',
    categoryIcon: Icons.data_object,
  );
}
