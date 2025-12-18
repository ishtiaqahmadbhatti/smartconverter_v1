import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class MobiToPdfPage extends StatelessWidget {
  const MobiToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Mobi To Pdf',
      inputExtension: 'mobi',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookMobiToPdfEndpoint,
      outputFolder: 'mobi-to-pdf',
    );
  }
}
