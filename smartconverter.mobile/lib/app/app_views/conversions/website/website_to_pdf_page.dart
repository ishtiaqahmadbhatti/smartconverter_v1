import '../../../app_modules/imports_module.dart';

class WebsiteToPdfPage extends StatefulWidget {
  const WebsiteToPdfPage({super.key});

  @override
  State<WebsiteToPdfPage> createState() => _WebsiteToPdfPageState();
}

class _WebsiteToPdfPageState extends State<WebsiteToPdfPage>
    with AdHelper, ConversionMixin {
  final TextEditingController _urlController = TextEditingController();

  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Enter a website URL to begin.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'Website URL';

  @override
  List<String> get allowedExtensions => []; // Not used for this tool

  @override
  String get conversionToolName => 'WebsiteToPdf';

  @override
  String get convertingMessage => 'Converting website...';

  @override
  String get successMessage => 'PDF ready!';

  @override
  bool get requiresInputFile => false;

  @override
  Future<Directory> get saveDirectory => FileManager.getWebsiteToPdfDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
    _urlController.addListener(_handleUrlChange);
  }

  @override
  void dispose() {
    fileNameController.removeListener(handleFileNameChange);
    _urlController.removeListener(_handleUrlChange);
    _urlController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  void _handleUrlChange() {
    if (_urlController.text.isNotEmpty && !model.fileNameEdited) {
      _updateSuggestedFileName();
    }
  }

  void _updateSuggestedFileName() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        model.suggestedBaseName = null;
        if (!model.fileNameEdited) {
          fileNameController.clear();
        }
      });
      return;
    }

    try {
      final uri = Uri.parse(url);
      String baseName = uri.host;
      if (baseName.startsWith('www.')) {
        baseName = baseName.substring(4);
      }
      if (uri.path.length > 1) {
        baseName += uri.path.replaceAll('/', '_');
      }

      final sanitized = sanitizeBaseName(baseName);
      setState(() {
        model.suggestedBaseName = sanitized;
        if (!model.fileNameEdited) {
          fileNameController.text = sanitized;
        }
      });
    } catch (e) {
      // Invalid URL, ignore
    }
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    // Note: file is null here because requiresInputFile is false
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      throw Exception('Please enter a valid URL.');
    }
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('URL must start with http:// or https://');
    }

    return await service.convertWebsiteToPdf(
      url: url,
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
          'Website to PDF',
          style: TextStyle(color: AppColors.textPrimary),
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
                  title: 'Convert Website to PDF',
                  description: 'Capture full-page versions of websites as PDF documents',
                  sourceIcon: Icons.web,
                  destinationIcon: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                
                // URL Input Field
                TextField(
                  controller: _urlController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'https://example.com',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.backgroundSurface,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                
                const SizedBox(height: 16),
                
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.pdf extension is added automatically',
                ),
                
                const SizedBox(height: 20),
                
                ConversionConvertButtonWidget(label: 'Convert to PDF',
                  icon: Icons.transform,
                  onPressed: convert,
                  isLoading: model.isConverting,
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
                      onSave: saveResult, // Handled by Mixin
                      title: 'PDF File Ready',
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

