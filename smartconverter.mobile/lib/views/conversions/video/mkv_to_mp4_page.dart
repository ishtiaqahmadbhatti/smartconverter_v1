import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MkvToMp4Page extends StatelessWidget {
  const MkvToMp4Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Convert MKV to MP4',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
