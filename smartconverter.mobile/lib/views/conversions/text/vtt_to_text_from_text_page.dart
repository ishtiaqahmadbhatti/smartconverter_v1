import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VttToTextFromTextPage extends StatelessWidget {
  const VttToTextFromTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Convert VTT to Text',
    categoryIcon: Icons.text_fields,
  );
}
