import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class Fb2ToPdfPage extends StatelessWidget {
  const Fb2ToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Fb2 To Pdf',
      inputExtension: 'fb2',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookFb2ToPdfEndpoint,
      outputFolder: 'fb2-to-pdf',
    );
  }
}
