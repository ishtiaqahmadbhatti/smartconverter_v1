import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PowerPointToPdfPage extends StatelessWidget {
  const PowerPointToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'PowerPoint To PDF',
    categoryIcon: Icons.description_outlined,
  );
}
