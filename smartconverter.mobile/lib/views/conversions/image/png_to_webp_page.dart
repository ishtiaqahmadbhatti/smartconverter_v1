import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToWebpPage extends StatelessWidget {
  const PngToWebpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to WebP',
      sourceFormat: 'PNG',
      targetFormat: 'WebP',
      sourceExtension: 'png',
      targetExtension: 'webp',
      apiEndpoint: ApiConfig.imagePngToWebpEndpoint,
    );
  }
}
