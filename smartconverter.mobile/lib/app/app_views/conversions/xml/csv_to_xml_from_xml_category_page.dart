import '../../../app_modules/imports_module.dart';

class CsvToXmlFromXmlCategoryPage extends StatefulWidget {
  const CsvToXmlFromXmlCategoryPage({super.key});

  @override
  State<CsvToXmlFromXmlCategoryPage> createState() => _CsvToXmlFromXmlCategoryPageState();
}

class _CsvToXmlFromXmlCategoryPageState extends State<CsvToXmlFromXmlCategoryPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a CSV file to begin.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  final TextEditingController rootNameController = TextEditingController(text: 'data');
  final TextEditingController recordNameController = TextEditingController(text: 'record');

  @override
  String get fileTypeLabel => 'CSV';

  @override
  List<String> get allowedExtensions => ['csv'];

  @override
  String get conversionToolName => 'CsvToXml';

  @override
  Future<Directory> get saveDirectory => FileManager.getCsvToXmlFromXmlCategoryDirectory();

  @override
  void dispose() {
    rootNameController.dispose();
    recordNameController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    return service.convertCsvToXml(
      file!,
      outputFilename: outputName,
      rootName: rootNameController.text,
      recordName: recordNameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('CSV to XML', style: TextStyle(color: AppColors.textPrimary)),
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
                        title: 'Convert CSV to XML',
                        description: 'Transform CSV data into structured XML.',
                        sourceIcon: Icons.grid_on,
                        destinationIcon: Icons.code,
                      ),
                      const SizedBox(height: 20),
                      ConversionActionButtonWidget(
                        isFileSelected: model.selectedFile != null,
                        onPickFile: pickFile,
                        onReset: resetForNewConversion,
                        isConverting: model.isConverting,
                        buttonText: 'Select CSV File',
                      ),
                      if (model.selectedFile != null) ...[
                        const SizedBox(height: 20),
                        ConversionSelectedFileCardWidget(
                          fileName: basename(model.selectedFile!.path),
                          fileSize: formatBytes(model.selectedFile!.lengthSync()),
                          fileIcon: Icons.table_chart,
                        ),
                        const SizedBox(height: 16),
                        ConversionFileNameFieldWidget(
                          controller: fileNameController,
                          suggestedName: model.suggestedBaseName,
                          extensionLabel: '.xml extension is added automatically',
                        ),
                        const SizedBox(height: 16),
                        _buildOptionsFields(),
                        const SizedBox(height: 20),
                        ConversionConvertButtonWidget(
                          isConverting: model.isConverting,
                          onConvert: convert,
                          buttonText: 'Convert to XML',
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
                            title: 'XML File Ready',
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

  Widget _buildOptionsFields() {
    return Column(
      children: [
        TextField(
          controller: rootNameController,
          decoration: InputDecoration(
            labelText: 'Root Element Name (Optional)',
            hintText: 'Default: data',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: recordNameController,
          decoration: InputDecoration(
            labelText: 'Record Element Name (Optional)',
            hintText: 'Default: record',
            prefixIcon: const Icon(Icons.list_alt),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}