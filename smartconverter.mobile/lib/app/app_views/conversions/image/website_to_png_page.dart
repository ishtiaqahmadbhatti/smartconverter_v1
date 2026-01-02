import '../../../app_modules/imports_module.dart';

class WebsiteToPngPage extends StatefulWidget {
  const WebsiteToPngPage({super.key});

  @override
  State<WebsiteToPngPage> createState() => _WebsiteToPngPageState();
}

class _WebsiteToPngPageState extends State<WebsiteToPngPage>
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
  List<String> get allowedExtensions => [];

  @override
  String get conversionToolName => 'WebsiteToPng';

  @override
  String get convertingMessage => 'Converting to PNG...';

  @override
  String get successMessage => 'PNG ready!';

  @override
  bool get requiresInputFile => false;

  @override
  Future<Directory> get saveDirectory => FileManager.getWebsiteToPngDirectory();

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
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      throw Exception('Please enter a valid URL.');
    }
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('URL must start with http:// or https://');
    }

    return await service.convertWebsiteToPng(
      url,
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
          'Website to PNG',
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
                  title: 'Convert Website to PNG',
                  description: 'Capture full-page screenshots of websites as PNG images',
                  sourceIcon: Icons.web,
                  destinationIcon: Icons.image,
                ),
                const SizedBox(height: 20),
                
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
                  extensionLabel: '.png extension is added automatically',
                ),
                
                const SizedBox(height: 20),
                
                ConversionConvertButtonWidget(label: 'Convert to PNG',
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
                  if (model.savedFilePath == null) ConversionFileSaveCardWidget(fileName: model.conversionResult!.fileName, isSaving: model.isSaving, onSave: saveResult, title: 'PNG Image Ready',) else ConversionResultCardWidget(savedFilePath: model.savedFilePath!, onShare: shareFile,)
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
