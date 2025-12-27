import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToYuvPage extends StatelessWidget {
  const WebpToYuvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to YUV',
      sourceFormat: 'WebP',
      targetFormat: 'YUV',
      sourceExtension: 'webp',
      targetExtension: 'yuv',
      apiEndpoint: ApiConfig.imageWebpToYuvEndpoint,
    );
  }
}
