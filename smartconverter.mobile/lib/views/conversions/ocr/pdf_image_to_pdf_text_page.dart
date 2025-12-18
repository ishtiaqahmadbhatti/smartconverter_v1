import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrPdfImageToPdfTextPage extends StatelessWidget {
  const OcrPdfImageToPdfTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert PDF Image to PDF Text',
      inputExtension: 'pdf',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ocrPdfImageToPdfTextEndpoint,
      outputFolder: 'pdf-image-to-pdf-text',
    );
  }
}
