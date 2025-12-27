import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class PdfToAzwPage extends StatelessWidget {
  const PdfToAzwPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Pdf To Azw',
      inputExtension: 'pdf',
      outputExtension: 'azw',
      apiEndpoint: ApiConfig.ebookPdfToAzwEndpoint,
      outputFolder: 'pdf-to-azw',
    );
  }
}
