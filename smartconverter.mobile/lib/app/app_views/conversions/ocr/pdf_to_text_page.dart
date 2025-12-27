import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrPdfToTextPage extends StatelessWidget {
  const OcrPdfToTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert PDF to Text',
      inputExtension: 'pdf',
      outputExtension: 'txt',
      apiEndpoint: ApiConfig.ocrPdfToTextEndpoint,
      outputFolder: 'pdf-to-text',
    );
  }
}
