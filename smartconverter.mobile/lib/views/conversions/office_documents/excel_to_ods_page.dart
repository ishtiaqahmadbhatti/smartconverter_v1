import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToOdsPage extends StatelessWidget {
  const ExcelToOdsPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Convert Excel to OpenOffice Calc ODS',
    categoryIcon: Icons.description_outlined,
  );
}
