import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class EpubToPdfPage extends StatelessWidget {
  const EpubToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Epub To Pdf',
      inputExtension: 'epub',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookEpubToPdfEndpoint,
      outputFolder: 'epub-to-pdf',
    );
  }
}
