import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class JpgToWebpPage extends StatelessWidget {
  const JpgToWebpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert JPG to WebP',
      sourceFormat: 'JPG',
      targetFormat: 'WebP',
      sourceExtension: 'jpg',
      targetExtension: 'webp',
      apiEndpoint: ApiConfig.imageJpgToWebpEndpoint,
    );
  }
}
