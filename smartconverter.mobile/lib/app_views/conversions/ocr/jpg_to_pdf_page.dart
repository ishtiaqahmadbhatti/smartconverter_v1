import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrJpgToPdfPage extends StatelessWidget {
  const OcrJpgToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert JPG to PDF',
      inputExtension: 'jpg',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ocrJpgToPdfEndpoint,
      outputFolder: 'jpg-to-pdf',
    );
  }
}
