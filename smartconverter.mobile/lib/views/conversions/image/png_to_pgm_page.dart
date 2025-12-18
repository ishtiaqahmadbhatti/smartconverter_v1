import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToPgmPage extends StatelessWidget {
  const PngToPgmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to PGM',
      sourceFormat: 'PNG',
      targetFormat: 'PGM',
      sourceExtension: 'png',
      targetExtension: 'pgm',
      apiEndpoint: ApiConfig.imagePngToPgmEndpoint,
    );
  }
}
