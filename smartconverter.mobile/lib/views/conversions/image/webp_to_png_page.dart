import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToPngPage extends StatelessWidget {
  const WebpToPngPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to PNG',
      sourceFormat: 'WebP',
      targetFormat: 'PNG',
      sourceExtension: 'webp',
      targetExtension: 'png',
      apiEndpoint: ApiConfig.imageWebpToPngEndpoint,
    );
  }
}
