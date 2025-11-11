import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToCsvPage extends StatelessWidget {
  const ExcelToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Excel To CSV',
    categoryIcon: Icons.description_outlined,
  );
}
