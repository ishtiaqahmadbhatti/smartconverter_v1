import '../../../app_modules/imports_module.dart';

class FbzToPdfPage extends StatefulWidget {
  const FbzToPdfPage({super.key});

  @override
  State<FbzToPdfPage> createState() => _FbzToPdfPageState();
}

class _FbzToPdfPageState extends State<FbzToPdfPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an FBZ file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Convert Fbz To Pdf';

  @override
  String get fileTypeLabel => 'FBZ';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['fbz'];

  @override
  Future<Directory> get saveDirectory => FileManager.getFbzToPdfDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
      file,
      outputFilename: outputName,
      endpoint: ApiConfig.ebookFbzToPdfEndpoint,
      outputExt: targetExtension,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          conversionToolName,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                ConversionHeaderCardWidget(
                  title: conversionToolName,
                  description: 'Transform FBZ eBooks into PDF documents.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.book, 
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select FBZ File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.book,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.$targetExtension extension is added automatically',
                ),
                const SizedBox(height: 20),
                if (model.selectedFile != null)
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
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
