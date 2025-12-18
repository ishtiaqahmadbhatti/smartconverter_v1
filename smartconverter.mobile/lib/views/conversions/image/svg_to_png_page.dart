import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class SvgToPngPage extends StatelessWidget {
  const SvgToPngPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert SVG to PNG',
      sourceFormat: 'SVG',
      targetFormat: 'PNG',
      sourceExtension: 'svg',
      targetExtension: 'png',
      apiEndpoint: ApiConfig.imageSvgToPngEndpoint,
    );
  }
}
