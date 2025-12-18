import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToFbzPage extends StatelessWidget {
  const PdfToFbzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Fbz',
      inputExtension: 'pdf',
      outputExtension: 'fbz',
      apiEndpoint: ApiConfig.ebookPdfToFbzEndpoint,
      outputFolder: 'pdf-to-fbz',
    );
  }
}
