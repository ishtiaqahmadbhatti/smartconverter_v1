import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlFormatterToolPage extends StatelessWidget {
  const XmlFormatterToolPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'XML Formatter',
    categoryIcon: Icons.format_align_left,
  );
}
