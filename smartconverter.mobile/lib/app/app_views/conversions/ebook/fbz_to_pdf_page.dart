import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class FbzToPdfPage extends StatelessWidget {
  const FbzToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Fbz To Pdf',
      inputExtension: 'fbz',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ebookFbzToPdfEndpoint,
      outputFolder: 'fbz-to-pdf',
    );
  }
}
