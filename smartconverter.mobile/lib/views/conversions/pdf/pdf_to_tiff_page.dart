import 'package:flutter/material.dart';

import '../image/pdf_to_tiff_page.dart';

class PdfToTiffPage extends StatelessWidget {
  const PdfToTiffPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const PdfToTiffImagePage(useImageCategoryStorage: false);
}
