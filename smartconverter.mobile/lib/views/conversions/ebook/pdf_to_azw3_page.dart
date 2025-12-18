import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToAzw3Page extends StatelessWidget {
  const PdfToAzw3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Azw3',
      inputExtension: 'pdf',
      outputExtension: 'azw3',
      apiEndpoint: ApiConfig.ebookPdfToAzw3Endpoint,
      outputFolder: 'pdf-to-azw3',
    );
  }
}
