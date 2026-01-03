import '../../../app_modules/imports_module.dart';

class PdfToJpgPage extends StatefulWidget {
  const PdfToJpgPage({super.key});

  @override
  State<PdfToJpgPage> createState() => _PdfToJpgPageState();
}

class _PdfToJpgPageState extends State<PdfToJpgPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a PDF file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'PDF to JPG';

  @override
  String get fileTypeLabel => 'PDF';

  @override
  String get targetExtension => 'jpg';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory => FileManager.getPdfToJpgImagesDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertPdfToJpg(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'PDF to JPG',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Convert PDF to JPG',
                  description: 'Convert PDF pages into high-quality JPG images.',
                  iconTarget: Icons.image,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select PDF File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.jpg extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to JPG',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult is PdfToImagesResult
                          ? '${(model.conversionResult as PdfToImagesResult).files.length} Images'
                          : (model.conversionResult as dynamic).fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: "JPG Files Ready",
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
                      showActions: model.conversionResult is! PdfToImagesResult,
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
