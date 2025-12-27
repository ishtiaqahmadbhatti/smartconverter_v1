import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class EpubToAzwPage extends StatelessWidget {
  const EpubToAzwPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Epub To Azw',
      inputExtension: 'epub',
      outputExtension: 'azw',
      apiEndpoint: ApiConfig.ebookEpubToAzwEndpoint,
      outputFolder: 'epub-to-azw',
    );
  }
}
