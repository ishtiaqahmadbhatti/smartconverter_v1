import '../../../app_modules/imports_module.dart';

class OxpsToPdfPage extends StatefulWidget {
  const OxpsToPdfPage({super.key});

  @override
  State<OxpsToPdfPage> createState() => _OxpsToPdfPageState();
}

class _OxpsToPdfPageState extends State<OxpsToPdfPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an OXPS file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'OXPS to PDF';

  @override
  String get fileTypeLabel => 'OXPS';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['oxps', 'xps'];

  @override
  Future<Directory> get saveDirectory => FileManager.getOxpsToPdfDirectory();

  @override
  Future<MarkdownToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) return null;
    return await service.convertOxpsToPdf(file, outputFilename: outputName);
  }

  @override
  Future<void> pickFile({String type = 'custom'}) async {
    // Override to use 'any' because OXPS is not supported by standard file picker types
    await super.pickFile(type: 'any');

    // Post-pick validation
    if (model.selectedFile != null) {
      final ext = extension(model.selectedFile!.path).toLowerCase().replaceAll('.', '');
      if (!allowedExtensions.contains(ext)) {
        setState(() {
          model.selectedFile = null;
          model.statusMessage = 'Invalid file type. Please select an OXPS or XPS file.';
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid file type. Please select an OXPS or XPS file.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Convert OXPS to PDF',
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
                  title: 'OXPS to PDF',
                  description: 'Convert OXPS documents to PDF format.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.description_outlined,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select OXPS File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
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
