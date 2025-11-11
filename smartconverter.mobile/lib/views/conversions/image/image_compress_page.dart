import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageCompressPage extends StatelessWidget {
  const ImageCompressPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Image Compress',
    categoryIcon: Icons.image_outlined,
  );
}
