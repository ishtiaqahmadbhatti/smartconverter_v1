import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToPpmPage extends StatelessWidget {
  const WebpToPpmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to PPM',
      sourceFormat: 'WebP',
      targetFormat: 'PPM',
      sourceExtension: 'webp',
      targetExtension: 'ppm',
      apiEndpoint: ApiConfig.imageWebpToPpmEndpoint,
    );
  }
}
