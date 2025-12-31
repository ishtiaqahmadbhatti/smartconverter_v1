import '../../../app_modules/imports_module.dart';

class ExcelToXmlOfficePage extends StatefulWidget {
  const ExcelToXmlOfficePage({super.key});

  @override
  State<ExcelToXmlOfficePage> createState() => _ExcelToXmlOfficePageState();
}

class _ExcelToXmlOfficePageState extends State<ExcelToXmlOfficePage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an Excel file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _rootNameController = TextEditingController(text: 'data');
  final TextEditingController _recordNameController = TextEditingController(text: 'record');
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Excel to XML';

  @override
  String get fileTypeLabel => 'Excel';

  @override
  String get targetExtension => 'xml';

  @override
  List<String> get allowedExtensions => ['xls', 'xlsx'];

  @override
  Future<Directory> get saveDirectory => FileManager.getOfficeExcelToXmlDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertExcelToXml(
      file,
      rootName: _rootNameController.text.trim(),
      recordName: _recordNameController.text.trim(),
    );
  }

  @override
  void dispose() {
    _rootNameController.dispose();
    _recordNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Convert Excel to XML',
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
                  title: 'Excel to XML',
                  description: 'Convert Excel data to structured XML.',
                  iconTarget: Icons.code,
                  iconSource: Icons.table_chart,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Excel File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.table_chart,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.xml extension is added automatically',
                ),
                const SizedBox(height: 16),
                 // Custom XML Options
                if (model.selectedFile != null) ...[
                  TextField(
                    controller: _rootNameController,
                    decoration: InputDecoration(
                      labelText: 'Root Element Name (Optional)',
                      hintText: 'Default: data',
                      prefixIcon: const Icon(Icons.title, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.backgroundSurface,
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recordNameController,
                    decoration: InputDecoration(
                      labelText: 'Record Element Name (Optional)',
                      hintText: 'Default: record',
                      prefixIcon: const Icon(Icons.list_alt, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.backgroundSurface,
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                ],
                
                if (model.selectedFile != null)
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to XML',
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
                      title: 'XML Ready',
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
