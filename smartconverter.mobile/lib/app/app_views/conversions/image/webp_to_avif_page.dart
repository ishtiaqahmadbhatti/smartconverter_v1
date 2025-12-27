import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToAvifPage extends StatelessWidget {
  const WebpToAvifPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to AVIF',
      sourceFormat: 'WebP',
      targetFormat: 'AVIF',
      sourceExtension: 'webp',
      targetExtension: 'avif',
      apiEndpoint: ApiConfig.imageWebpToAvifEndpoint,
    );
  }
}
