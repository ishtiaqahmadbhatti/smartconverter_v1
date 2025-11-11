import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class BsonToExcelPage extends StatelessWidget {
  const BsonToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Convert BSON to Excel',
    categoryIcon: Icons.description_outlined,
  );
}
