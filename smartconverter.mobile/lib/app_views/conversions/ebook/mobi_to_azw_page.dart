import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ebook_common_page.dart';

class MobiToAzwPage extends StatelessWidget {
  const MobiToAzwPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbookCommonPage(
      toolName: 'Convert Mobi To Azw',
      inputExtension: 'mobi',
      outputExtension: 'azw',
      apiEndpoint: ApiConfig.ebookMobiToAzwEndpoint,
      outputFolder: 'mobi-to-azw',
    );
  }
}
