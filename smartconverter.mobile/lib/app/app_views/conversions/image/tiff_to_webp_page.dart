import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class TiffToWebpPage extends StatelessWidget {
  const TiffToWebpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert TIFF to WebP',
      sourceFormat: 'TIFF',
      targetFormat: 'WebP',
      sourceExtension: 'tiff',
      targetExtension: 'webp',
      apiEndpoint: ApiConfig.imageTiffToWebpEndpoint,
    );
  }
}
