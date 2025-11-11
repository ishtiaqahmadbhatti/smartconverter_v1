import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OdsToExcelPage extends StatelessWidget {
  const OdsToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Convert OpenOffice Calc ODS to Excel',
    categoryIcon: Icons.description_outlined,
  );
}
