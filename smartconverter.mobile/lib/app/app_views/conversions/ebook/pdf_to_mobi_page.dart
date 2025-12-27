import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToMobiPage extends StatelessWidget {
  const PdfToMobiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Mobi',
      inputExtension: 'pdf',
      outputExtension: 'mobi',
      apiEndpoint: ApiConfig.ebookPdfToMobiEndpoint,
      outputFolder: 'pdf-to-mobi',
    );
  }
}
