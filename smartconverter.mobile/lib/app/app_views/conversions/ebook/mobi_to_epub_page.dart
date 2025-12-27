import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class MobiToEpubPage extends StatelessWidget {
  const MobiToEpubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Mobi To Epub',
      inputExtension: 'mobi',
      outputExtension: 'epub',
      apiEndpoint: ApiConfig.ebookMobiToEpubEndpoint,
      outputFolder: 'mobi-to-epub',
    );
  }
}
