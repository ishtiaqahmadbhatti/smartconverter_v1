
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import 'ebook_common_page.dart';

class MarkdownToEpubPage extends StatefulWidget {
  const MarkdownToEpubPage({super.key});

  @override
  State<MarkdownToEpubPage> createState() => _MarkdownToEpubPageState();
}

class _MarkdownToEpubPageState extends State<MarkdownToEpubPage> {
  final TextEditingController _titleController = TextEditingController(text: 'Converted Book');
  final TextEditingController _authorController = TextEditingController(text: 'Unknown');

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EbookCommonPage(
      toolName: 'Convert Markdown to ePUB',
      inputExtension: 'md',
      outputExtension: 'epub',
      apiEndpoint: ApiConfig.ebookMarkdownToEpubEndpoint,
      outputFolder: 'markdown-to-epub',
      extraParamsBuilder: () {
        return {
          'title': _titleController.text.trim().isEmpty ? 'Converted Book' : _titleController.text.trim(),
          'author': _authorController.text.trim().isEmpty ? 'Unknown' : _authorController.text.trim(),
        };
      },
      extraWidgetsBuilder: (context, setState) {
        return [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Book Title',
              filled: true,
              fillColor: AppColors.backgroundSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.title),
            ),
             style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
             controller: _authorController,
            decoration: InputDecoration(
              labelText: 'Author Name',
              filled: true,
              fillColor: AppColors.backgroundSurface,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
               prefixIcon: const Icon(Icons.person),
            ),
             style: const TextStyle(color: AppColors.textPrimary),
          ),
        ];
      },
    );
  }
}
