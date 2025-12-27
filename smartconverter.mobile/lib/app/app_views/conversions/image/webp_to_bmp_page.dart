import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToBmpPage extends StatelessWidget {
  const WebpToBmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to BMP',
      sourceFormat: 'WebP',
      targetFormat: 'BMP',
      sourceExtension: 'webp',
      targetExtension: 'bmp',
      apiEndpoint: ApiConfig.imageWebpToBmpEndpoint,
    );
  }
}
