import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToSvgPage extends StatelessWidget {
  const PngToSvgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to SVG',
      sourceFormat: 'PNG',
      targetFormat: 'SVG',
      sourceExtension: 'png',
      targetExtension: 'svg',
      apiEndpoint: ApiConfig.imagePngToSvgEndpoint,
    );
  }
}
