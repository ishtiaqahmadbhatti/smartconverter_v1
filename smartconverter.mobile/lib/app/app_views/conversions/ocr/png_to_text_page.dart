import '../../../app_modules/imports_module.dart';

class PngToTextPage extends StatefulWidget {
  const PngToTextPage({super.key});

  @override
  State<PngToTextPage> createState() => _PngToTextPageState();
}

class _PngToTextPageState extends State<PngToTextPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a PNG file to extract text.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'PNG';

  @override
  List<String> get allowedExtensions => ['png'];

  @override
  String get conversionToolName => 'PngToText';

  @override
  Future<Directory> get saveDirectory => FileManager.getImageToTextDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    return service.convertOcrPngToText(file!, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('PNG to Text (OCR)', style: TextStyle(color: AppColors.textPrimary)),
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
                        title: 'PNG to Text',
                        description: 'Extract text from PNG images using OCR technology',
                        sourceIcon: Icons.image,
                        destinationIcon: Icons.text_snippet,
                      ),
                      const SizedBox(height: 20),
                      ConversionActionButtonWidget(
                        isFileSelected: model.selectedFile != null,
                        onPickFile: pickFile,
                        onReset: resetForNewConversion,
                        isConverting: model.isConverting,
                        buttonText: 'Select PNG File',
                      ),
                      if (model.selectedFile != null) ...[
                        const SizedBox(height: 20),
                        ConversionSelectedFileCardWidget(
                          fileName: basename(model.selectedFile!.path),
                          fileSize: formatBytes(model.selectedFile!.lengthSync()),
                          fileIcon: Icons.image,
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
