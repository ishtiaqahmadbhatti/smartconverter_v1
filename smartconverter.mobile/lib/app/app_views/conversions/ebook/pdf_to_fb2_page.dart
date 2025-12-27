import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToFb2Page extends StatelessWidget {
  const PdfToFb2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Fb2',
      inputExtension: 'pdf',
      outputExtension: 'fb2',
      apiEndpoint: ApiConfig.ebookPdfToFb2Endpoint,
      outputFolder: 'pdf-to-fb2',
    );
  }
}
