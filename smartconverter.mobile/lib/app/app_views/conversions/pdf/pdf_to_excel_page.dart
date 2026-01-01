import '../../../app_modules/imports_module.dart';

class PdfToExcelPage extends StatefulWidget {
  const PdfToExcelPage({super.key});

  @override
  State<PdfToExcelPage> createState() => _PdfToExcelPageState();
}

class _PdfToExcelPageState extends State<PdfToExcelPage> with AdHelper, ConversionMixin {
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
  String get conversionToolName => 'PDF to Excel';
  
  // Use specific tool name for Ad gate if needed, or default
  @override
  String get adGateToolName => 'PDF-to-Excel';

  @override
  String get fileTypeLabel => 'PDF';

  @override
  String get targetExtension => 'xlsx';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory => FileManager.getPdfToExcelDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertPdfToExcel(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Convert PDF to Excel',
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
                  title: 'PDF to Excel',
                  description: 'Turn your PDF content into organized Excel sheets that you can edit, filter, and analyze.',
                  iconTarget: Icons.table_chart,
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
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.xlsx extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to Excel',
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
                      title: 'Excel Ready',
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
