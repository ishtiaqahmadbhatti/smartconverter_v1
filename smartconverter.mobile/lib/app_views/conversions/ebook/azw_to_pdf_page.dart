import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class AzwToPdfPage extends StatelessWidget {
  const AzwToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Azw To Pdf',
      inputExtension: 'azw',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookAzwToPdfEndpoint,
      outputFolder: 'azw-to-pdf',
    );
  }
}
