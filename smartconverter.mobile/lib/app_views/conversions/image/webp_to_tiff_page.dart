import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToTiffPage extends StatelessWidget {
  const WebpToTiffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to TIFF',
      sourceFormat: 'WebP',
      targetFormat: 'TIFF',
      sourceExtension: 'webp',
      targetExtension: 'tiff',
      apiEndpoint: ApiConfig.imageWebpToTiffEndpoint,
    );
  }
}
