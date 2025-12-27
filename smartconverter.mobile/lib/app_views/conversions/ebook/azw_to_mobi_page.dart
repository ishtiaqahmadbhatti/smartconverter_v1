import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class AzwToMobiPage extends StatelessWidget {
  const AzwToMobiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Azw To Mobi',
      inputExtension: 'azw',
      outputExtension: 'mobi',
      apiEndpoint: ApiConfig.ebookAzwToMobiEndpoint,
      outputFolder: 'azw-to-mobi',
    );
  }
}
