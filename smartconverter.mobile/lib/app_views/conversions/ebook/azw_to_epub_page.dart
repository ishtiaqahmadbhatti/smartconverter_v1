import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class AzwToEpubPage extends StatelessWidget {
  const AzwToEpubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Azw To Epub',
      inputExtension: 'azw',
      outputExtension: 'epub',
      apiEndpoint: ApiConfig.ebookAzwToEpubEndpoint,
      outputFolder: 'azw-to-epub',
    );
  }
}
