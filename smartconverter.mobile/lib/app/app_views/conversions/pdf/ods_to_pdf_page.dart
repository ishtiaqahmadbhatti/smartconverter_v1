import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class OdsToPdfFromPdfCategoryPage extends StatelessWidget {
  const OdsToPdfFromPdfCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'pdf_conversion',
    toolName: 'Convert OpenOffice Calc ODS to PDF',
    categoryIcon: Icons.picture_as_pdf_outlined,
  );
}
