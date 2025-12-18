import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class AvifToWebpPage extends StatelessWidget {
  const AvifToWebpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert AVIF to WebP',
      sourceFormat: 'AVIF',
      targetFormat: 'WebP',
      sourceExtension: 'avif',
      targetExtension: 'webp',
      apiEndpoint: ApiConfig.imageAvifToWebpEndpoint,
    );
  }
}
