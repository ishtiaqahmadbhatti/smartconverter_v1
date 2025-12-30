import '../../../app_modules/imports_module.dart';


class JsonToXmlPage extends StatefulWidget {
  const JsonToXmlPage({super.key});

  @override
  State<JsonToXmlPage> createState() => _JsonToXmlPageState();
}

class _JsonToXmlPageState extends State<JsonToXmlPage>
    with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a JSON file to begin.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  final TextEditingController _rootElementController =
      TextEditingController(text: 'root');

  @override
  void dispose() {
    _rootElementController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  @override
  String get conversionToolName => 'JsonToXml';

  // Not in mixin
  String get conversionTitle => 'Convert JSON to XML';
  String get conversionDescription => 'Transform JSON files into XML format.';
  IconData get iconA => Icons.data_object;
  IconData get iconB => Icons.code;
  String get buttonLabel => 'Convert to XML';

  @override
  String get fileTypeLabel => 'JSON';

  @override
  List<String> get allowedExtensions => ['json'];

  @override
  Future<Directory> get saveDirectory => FileManager.getJsonToXmlDirectory();

  @override
  String get targetExtension => 'xml';

  @override
  Future<ImageToPdfResult?> performConversion(
      File? file, String? outputName) async {
    final rootElement = _rootElementController.text.trim().isNotEmpty
        ? _rootElementController.text.trim()
        : 'root';

    return service.convertJsonToXml(
      file!,
      outputFilename: outputName,
      rootElement: rootElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer: const DrawerMenuWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _rootElementController,
                    decoration: InputDecoration(
                      labelText: 'Root Element Name (optional)',
                      hintText: 'Default: root',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.backgroundSurface,
                      helperText: 'Name of the root XML element',
                      helperStyle:
                          const TextStyle(color: AppColors.textSecondary),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
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
                    title: 'XML File Ready',
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
