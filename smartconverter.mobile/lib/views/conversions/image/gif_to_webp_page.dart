import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class GifToWebpPage extends StatelessWidget {
  const GifToWebpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert GIF to WebP',
      sourceFormat: 'GIF',
      targetFormat: 'WebP',
      sourceExtension: 'gif',
      targetExtension: 'webp',
      apiEndpoint: ApiConfig.imageGifToWebpEndpoint,
    );
  }
}
