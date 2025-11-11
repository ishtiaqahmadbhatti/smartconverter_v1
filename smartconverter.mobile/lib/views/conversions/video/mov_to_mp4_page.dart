import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MovToMp4Page extends StatelessWidget {
  const MovToMp4Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'video_conversion',
    toolName: 'Convert MOV to MP4',
    categoryIcon: Icons.movie_creation_outlined,
  );
}
