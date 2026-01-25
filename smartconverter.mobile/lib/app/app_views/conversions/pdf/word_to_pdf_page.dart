import '../../../app_modules/imports_module.dart';

class WordToPdfPage extends StatefulWidget {
  const WordToPdfPage({super.key});

  @override
  State<WordToPdfPage> createState() => _WordToPdfPageState();
}

class _WordToPdfPageState extends State<WordToPdfPage>
    with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(
    statusMessage: 'Select a Word file to begin.',
  );
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Word to PDF';

  @override
  String get fileTypeLabel => 'Word';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['doc', 'docx'];

  @override
  Future<Directory> get saveDirectory => FileManager.getWordToPdfDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(
    File? file,
    String? outputName,
  ) async {
    if (file == null) throw Exception('File is null');
    return await service.convertWordToPdf(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Convert Word to PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
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
                  title: 'Word to PDF',
                  description:
                      'Transform Word documents (DOC, DOCX) to PDF format.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.description,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Word File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.description,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.pdf extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to PDF',
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
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'PDF File Ready',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
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
