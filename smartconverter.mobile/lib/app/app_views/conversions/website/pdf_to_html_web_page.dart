import '../../../app_modules/imports_module.dart';

class PdfToHtmlWebPage extends StatefulWidget {
  const PdfToHtmlWebPage({super.key});

  @override
  State<PdfToHtmlWebPage> createState() => _PdfToHtmlWebPageState();
}

class _PdfToHtmlWebPageState extends State<PdfToHtmlWebPage>
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Select a PDF file to convert.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'PDF';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  String get conversionToolName => 'PdfToHtmlWeb';

  @override
  String get convertingMessage => 'Converting PDF to HTML...';

  @override
  String get successMessage => 'HTML generated successfully!';

  @override
  String get targetExtension => '.html';

  @override
  Future<Directory> get saveDirectory => FileManager.getWebsitePdfToHtmlDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    fileNameController.removeListener(handleFileNameChange);
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('Please select a PDF file');
    
    return await service.convertPdfToHtml(
      file,
      outputFilename: outputName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PDF to HTML',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Convert PDF to HTML',
                  description: 'Extract text from PDF documents as HTML',
                  sourceIcon: Icons.picture_as_pdf,
                  destinationIcon: Icons.code,
                ),
                const SizedBox(height: 20),
                
                ConversionActionButtonWidget(
                  isFileSelected: model.selectedFile != null,
                  onPickFile: pickFile,
                  onReset: () => resetForNewConversion(customStatus: 'Select a PDF file to begin.'),
                  isConverting: model.isConverting,
                  buttonText: 'Select PDF File',
                ),
                
                if (model.selectedFile != null) ...[
                  const SizedBox(height: 16),
                  ConversionSelectedFileCardWidget(
                    fileTypeLabel: fileTypeLabel,
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.description,
                    onRemove: () => resetForNewConversion(customStatus: 'Select a PDF file to begin.'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.html extension is added automatically',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ConversionConvertButtonWidget(
                    label: 'Convert to HTML',
                    icon: Icons.transform,
                    onPressed: convert,
                    isLoading: model.isConverting,
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
                      title: 'HTML File Ready',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: getBannerAdWidget(),
    );
  }
}
