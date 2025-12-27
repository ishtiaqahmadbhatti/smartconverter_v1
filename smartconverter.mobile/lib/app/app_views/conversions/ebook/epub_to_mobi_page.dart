import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class EpubToMobiPage extends StatelessWidget {
  const EpubToMobiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Epub To Mobi',
      inputExtension: 'epub',
      outputExtension: 'mobi',
      apiEndpoint: ApiConfig.ebookEpubToMobiEndpoint,
      outputFolder: 'epub-to-mobi',
    );
  }
}
