import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToEpubPage extends StatelessWidget {
  const PdfToEpubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Epub',
      inputExtension: 'pdf',
      outputExtension: 'epub',
      apiEndpoint: ApiConfig.ebookPdfToEpubEndpoint,
      outputFolder: 'pdf-to-epub',
    );
  }
}
