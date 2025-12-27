import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class SvgToJpgPage extends StatelessWidget {
  const SvgToJpgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert SVG to JPG',
      sourceFormat: 'SVG',
      targetFormat: 'JPG',
      sourceExtension: 'svg',
      targetExtension: 'jpg',
      apiEndpoint: ApiConfig.imageSvgToJpgEndpoint,
    );
  }
}
