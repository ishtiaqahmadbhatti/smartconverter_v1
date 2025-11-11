import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AviToMp4Page extends StatelessWidget {
  const AviToMp4Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Convert AVI to MP4',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
