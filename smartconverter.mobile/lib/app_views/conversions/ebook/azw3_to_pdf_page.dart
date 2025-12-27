import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ebook_common_page.dart';

class Azw3ToPdfPage extends StatelessWidget {
  const Azw3ToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Azw3 To Pdf',
      inputExtension: 'azw3',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookAzw3ToPdfEndpoint,
      outputFolder: 'azw3-to-pdf',
    );
  }
}
