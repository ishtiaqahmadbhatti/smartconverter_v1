import '../../../app_modules/imports_module.dart';

class OcrTextExtractionPage extends StatefulWidget {
  const OcrTextExtractionPage({super.key});

  @override
  State<OcrTextExtractionPage> createState() => _OcrTextExtractionPageState();
}

class _OcrTextExtractionPageState extends State<OcrTextExtractionPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a file (PDF, JPG, PNG) to extract text.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'File';

  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png', 'pdf'];

  @override
  String get conversionToolName => 'OcrTextExtraction';

  @override
  Future<Directory> get saveDirectory => FileManager.getImageToTextDirectory(); // Using generic text directory

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    final path = file!.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return service.convertOcrJpgToText(file, outputFilename: outputName);
    } else if (path.endsWith('.png')) {
      return service.convertOcrPngToText(file, outputFilename: outputName);
    } else if (path.endsWith('.pdf')) {
      return service.convertOcrPdfToText(file, outputFilename: outputName);
    } else {
      throw Exception('Unsupported file format.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('OCR Text Extraction', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const ConversionHeaderCardWidget(
                        title: 'OCR Extraction',
                        description: 'Extract text from various documents (Images, PDF)',
                        sourceIcon: Icons.document_scanner,
                        destinationIcon: Icons.text_snippet,
                      ),
                      const SizedBox(height: 20),
                      ConversionActionButtonWidget(
                        isFileSelected: model.selectedFile != null,
                        onPickFile: pickFile,
                        onReset: resetForNewConversion,
                        isConverting: model.isConverting,
                        buttonText: 'Select File',
                      ),
                      if (model.selectedFile != null) ...[
                        const SizedBox(height: 20),
                        ConversionSelectedFileCardWidget(
                          fileName: basename(model.selectedFile!.path),
                          fileSize: formatBytes(model.selectedFile!.lengthSync()),
                          fileIcon: Icons.description,
                        ),
                        const SizedBox(height: 16),
                        ConversionFileNameFieldWidget(
                          controller: fileNameController,
                          suggestedName: model.suggestedBaseName,
                          extensionLabel: '.txt extension is added automatically',
                        ),
                        const SizedBox(height: 20),
                        ConversionConvertButtonWidget(
                          isConverting: model.isConverting,
                          onConvert: convert,
                          buttonText: 'Extract Text',
                        ),
                      ],
                      const SizedBox(height: 20),
                      ConversionStatusWidget(
                          statusMessage: model.statusMessage,
                          isConverting: model.isConverting,
                          conversionResult: model.conversionResult,
                      ),
                      if (model.conversionResult != null) ...[
                        const SizedBox(height: 20),
                        if (model.savedFilePath == null)
                           ConversionFileSaveCardWidget(
                            fileName: model.conversionResult!.fileName,
                            isSaving: model.isSaving,
                            onSave: saveResult,
                            title: 'Text File Ready',
                          )
                        else
                          ConversionResultCardWidget(
                            savedFilePath: model.savedFilePath!,
                            onShare: shareFile,
                          ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: getBannerAdWidget(),
    );
  }
}
