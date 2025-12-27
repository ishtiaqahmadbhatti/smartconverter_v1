import 'package:flutter/material.dart';

import '../image/pdf_to_jpg_page.dart';

class PdfToJpgPage extends StatelessWidget {
  const PdfToJpgPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PdfToJpgImagePage(useImageCategoryStorage: false);
}
