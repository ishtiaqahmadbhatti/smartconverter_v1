import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageFormatConversionPage extends StatelessWidget {
  const ImageFormatConversionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Image Format Conversion',
    categoryIcon: Icons.image_outlined,
  );
}
