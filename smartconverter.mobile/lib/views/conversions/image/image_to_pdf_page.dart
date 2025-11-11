import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ImageToPdfImagePage extends StatelessWidget {
  const ImageToPdfImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Image To PDF',
    categoryIcon: Icons.image_outlined,
  );
}
