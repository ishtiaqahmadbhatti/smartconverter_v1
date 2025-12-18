import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToJpegPage extends StatelessWidget {
  const WebpToJpegPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to JPEG',
      sourceFormat: 'WebP',
      targetFormat: 'JPEG',
      sourceExtension: 'webp',
      targetExtension: 'jpg',
      apiEndpoint: ApiConfig.imageWebpToJpegEndpoint,
    );
  }
}
