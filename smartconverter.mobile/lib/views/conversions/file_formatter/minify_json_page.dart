
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'file_formatter_common_page.dart';

class JsonMinifierPage extends StatelessWidget {
  const JsonMinifierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileFormatterCommonPage(
      toolName: 'Minify JSON',
      inputExtension: 'json',
      outputExtension: 'json',
      apiEndpoint: ApiConfig.fileMinifyJsonEndpoint,
      outputFolder: 'minified_json',
      // No extra params for minify
    );
  }
}
