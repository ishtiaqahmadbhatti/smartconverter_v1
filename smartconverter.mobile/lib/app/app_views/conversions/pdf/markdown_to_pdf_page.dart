import '../../../app_modules/imports_module.dart';

class MarkdownToPdfPage extends StatefulWidget {
  const MarkdownToPdfPage({super.key});

  @override
  State<MarkdownToPdfPage> createState() => _MarkdownToPdfPageState();
}

class _MarkdownToPdfPageState extends State<MarkdownToPdfPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a Markdown file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Markdown to PDF';

  @override
  String get fileTypeLabel => 'Markdown';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['md', 'markdown'];

  @override
  Future<Directory> get saveDirectory => FileManager.getMarkdownToPdfDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertMarkdownToPdf(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Markdown to PDF',
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
                  title: 'Convert Markdown to PDF',
                  description: 'Convert your Markdown files (.md) to PDF format with proper formatting.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.description_outlined,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Markdown File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.description_outlined,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.pdf extension is added automatically',
                ),
                const SizedBox(height: 20),
                ConversionConvertButtonWidget(
                  onConvert: convert,
                  isConverting: model.isConverting,
                  isEnabled: model.selectedFile != null,
                  buttonText: 'Convert to PDF',
                ),
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
