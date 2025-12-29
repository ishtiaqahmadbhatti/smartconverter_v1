import '../../../app_modules/imports_module.dart';

class ImageToTextPage extends StatefulWidget {
  const ImageToTextPage({super.key});

  @override
  State<ImageToTextPage> createState() => _ImageToTextPageState();
}

class _ImageToTextPageState extends State<ImageToTextPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select an image (JPG/PNG) to extract text.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'Image';

  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png'];

  @override
  String get conversionToolName => 'ImageToText';

  @override
  Future<Directory> get saveDirectory => FileManager.getImageToTextDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    final path = file!.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return service.convertOcrJpgToText(file, outputFilename: outputName);
    } else if (path.endsWith('.png')) {
      return service.convertOcrPngToText(file, outputFilename: outputName);
    } else {
      throw Exception('Unsupported file format. Please use JPG or PNG.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Image to Text (OCR)', style: TextStyle(color: AppColors.textPrimary)),
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
                        title: 'Image to Text',
                        description: 'Extract text from images using OCR technology',
                        sourceIcon: Icons.image,
                        destinationIcon: Icons.text_snippet,
                      ),
                      const SizedBox(height: 20),
                      ConversionActionButtonWidget(
                        isFileSelected: model.selectedFile != null,
                        onPickFile: pickFile,
                        onReset: resetForNewConversion,
                        isConverting: model.isConverting,
                        buttonText: 'Select Image',
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
