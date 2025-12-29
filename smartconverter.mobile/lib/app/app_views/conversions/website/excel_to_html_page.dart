import '../../../app_modules/imports_module.dart';

class ExcelToHtmlWebPage extends StatefulWidget {
  const ExcelToHtmlWebPage({super.key});

  @override
  State<ExcelToHtmlWebPage> createState() => _ExcelToHtmlWebPageState();
}

class _ExcelToHtmlWebPageState extends State<ExcelToHtmlWebPage>
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Select an Excel file to convert.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'Excel';

  @override
  List<String> get allowedExtensions => ['xls', 'xlsx'];

  @override
  String get conversionToolName => 'ExcelToHtmlWeb';

  @override
  String get convertingMessage => 'Converting Excel to HTML...';

  @override
  String get successMessage => 'HTML generated successfully!';

  @override
  String get targetExtension => '.html';

  @override
  Future<Directory> get saveDirectory => FileManager.getWebsiteExcelToHtmlDirectory();

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
    if (file == null) throw Exception('Please select an Excel file');
    
    return await service.convertExcelToHtml(
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
          'Excel to HTML',
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
                  title: 'Convert Excel to HTML',
                  description: 'Transform Excel spreadsheets into HTML tables',
                  sourceIcon: Icons.table_chart,
                  destinationIcon: Icons.code,
                ),
                const SizedBox(height: 20),
                
                ConversionActionButtonWidget(
                  isFileSelected: model.selectedFile != null,
                  onPickFile: pickFile,
                  onReset: () => resetForNewConversion(customStatus: 'Select an Excel file to convert.'),
                  isConverting: model.isConverting,
                  buttonText: 'Select Excel File',
                ),
                
                if (model.selectedFile != null) ...[
                  const SizedBox(height: 16),
                  ConversionSelectedFileCardWidget(
                    fileTypeLabel: fileTypeLabel,
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.description,
                    onRemove: () => resetForNewConversion(customStatus: 'Select an Excel file to convert.'),
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
