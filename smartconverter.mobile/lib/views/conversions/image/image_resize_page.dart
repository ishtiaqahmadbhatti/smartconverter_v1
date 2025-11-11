import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageResizePage extends StatelessWidget {
  const ImageResizePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Image Resize',
    categoryIcon: Icons.image_outlined,
  );
}
