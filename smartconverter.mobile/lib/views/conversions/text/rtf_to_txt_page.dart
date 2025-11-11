import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class RtfToTxtPage extends StatelessWidget {
  const RtfToTxtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'RTF To TXT',
    categoryIcon: Icons.text_fields,
  );
}
