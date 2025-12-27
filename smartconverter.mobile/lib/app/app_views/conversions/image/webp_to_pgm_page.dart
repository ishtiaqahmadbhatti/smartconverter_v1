import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToPgmPage extends StatelessWidget {
  const WebpToPgmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to PGM',
      sourceFormat: 'WebP',
      targetFormat: 'PGM',
      sourceExtension: 'webp',
      targetExtension: 'pgm',
      apiEndpoint: ApiConfig.imageWebpToPgmEndpoint,
    );
  }
}
