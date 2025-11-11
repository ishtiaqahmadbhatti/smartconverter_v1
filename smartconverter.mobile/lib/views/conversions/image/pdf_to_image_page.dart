import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToImageImagePage extends StatelessWidget {
  const PdfToImageImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'PDF To Image',
    categoryIcon: Icons.image_outlined,
  );
}
