import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class JpgToPngPage extends StatelessWidget {
  const JpgToPngPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert JPG to PNG',
      sourceFormat: 'JPG',
      targetFormat: 'PNG',
      sourceExtension: 'jpg',
      targetExtension: 'png',
      apiEndpoint: ApiConfig.imageJpgToPngEndpoint,
    );
  }
}
