import '../../../app_modules/imports_module.dart';


class JsonToExcelPage extends StatefulWidget {
  const JsonToExcelPage({super.key});

  @override
  State<JsonToExcelPage> createState() => _JsonToExcelPageState();
}

class _JsonToExcelPageState extends State<JsonToExcelPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a JSON file to begin.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  @override
  String get conversionToolName => 'JsonToExcel';

  // Not in mixin
  String get conversionTitle => 'Convert JSON to Excel';
  String get conversionDescription => 'Transform JSON files into structured Excel format.';
  IconData get iconA => Icons.data_object;
  IconData get iconB => Icons.table_chart;
  String get buttonLabel => 'Convert to Excel';

  @override
  String get fileTypeLabel => 'JSON';

  @override
  List<String> get allowedExtensions => ['json'];

  @override
  Future<Directory> get saveDirectory =>
      FileManager.getJsonJsonToExcelDirectory();

  @override
  String get targetExtension => 'xlsx';

  @override
  Future<ImageToPdfResult?> performConversion(
      File? file, String? outputName) async {
    return service.convertJsonToExcel(
      file!,
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
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          conversionTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConversionHeaderCardWidget(
                  title: conversionTitle,
                  description: conversionDescription,
                  sourceIcon: iconA,
                  destinationIcon: iconB,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  isFileSelected: model.selectedFile != null,
                  onPickFile: pickFile,
                  onReset: resetForNewConversion,
                  isConverting: model.isConverting,
                  buttonText: 'Select $fileTypeLabel File',
                ),
                if (model.selectedFile != null) ...[
                  const SizedBox(height: 20),
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: iconA,
                  ),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.$targetExtension extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    isConverting: model.isConverting,
                    onConvert: convert,
                    buttonText: buttonLabel,
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                if (model.savedFilePath != null) ...[
                  const SizedBox(height: 20),
                  ConversionResultCardWidget(
                    savedFilePath: model.savedFilePath!,
                    onShare: shareFile,
                  ),
                ] else if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  ConversionFileSaveCardWidget(
                    fileName: model.conversionResult!.fileName,
                    isSaving: model.isSaving,
                    onSave: saveResult,
                    title: 'Excel File Ready',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
