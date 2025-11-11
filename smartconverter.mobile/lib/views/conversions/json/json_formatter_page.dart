import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonFormatterPage extends StatelessWidget {
  const JsonFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'JSON Formatter',
    categoryIcon: Icons.data_object,
  );
}
