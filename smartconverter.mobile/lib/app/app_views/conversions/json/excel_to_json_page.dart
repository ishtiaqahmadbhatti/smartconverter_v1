import '../../../app_modules/imports_module.dart';


class ExcelToJsonPage extends StatefulWidget {
  const ExcelToJsonPage({super.key});

  @override
  State<ExcelToJsonPage> createState() => _ExcelToJsonPageState();
}

class _ExcelToJsonPageState extends State<ExcelToJsonPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select an Excel file to begin.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  @override
  String get conversionToolName => 'ExcelToJson';

  // Not in mixin
  String get conversionTitle => 'Convert Excel to JSON';
  String get conversionDescription => 'Transform Excel spreadsheets into JSON format.';
  IconData get iconA => Icons.table_chart;
  IconData get iconB => Icons.data_object;
  String get buttonLabel => 'Convert to JSON';

  @override
  String get fileTypeLabel => 'Excel';

  @override
  List<String> get allowedExtensions => ['xls', 'xlsx'];

  @override
  Future<Directory> get saveDirectory => FileManager.getExcelToJsonDirectory();

  @override
  String get targetExtension => 'json';

  @override
  Future<ImageToPdfResult?> performConversion(
      File? file, String? outputName) async {
    return service.convertExcelToJson(
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
                    title: 'JSON File Ready',
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
