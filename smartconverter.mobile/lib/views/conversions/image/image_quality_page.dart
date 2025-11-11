import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageQualityPage extends StatelessWidget {
  const ImageQualityPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Image Quality',
    categoryIcon: Icons.image_outlined,
  );
}
