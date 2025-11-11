import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToPdfPage extends StatelessWidget {
  const ExcelToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Excel To PDF',
    categoryIcon: Icons.description_outlined,
  );
}
