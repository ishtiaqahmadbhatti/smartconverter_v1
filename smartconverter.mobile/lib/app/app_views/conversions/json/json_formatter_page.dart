// ignore_for_file: deprecated_member_use, unused_local_variable

import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;


class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  State<JsonFormatterPage> createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> 
    with AdHelper<JsonFormatterPage>, ConversionMixin<JsonFormatterPage> {
  
  final TextEditingController _jsonTextController = TextEditingController();
  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select input method to begin.',
  );
  
  // Toggle between file upload and text input
  bool _useTextInput = false;
  int _indentSize = 2;
  String? _formattedJsonPreview;

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    fileNameController.removeListener(handleFileNameChange);
    fileNameController.dispose();
    _jsonTextController.dispose();
    super.dispose();
  }

  @override
  String get conversionToolName => 'JsonFormatter';

  @override
  String get fileTypeLabel => _useTextInput ? 'JSON Text' : 'JSON';

  @override
  List<String> get allowedExtensions => ['json', 'txt'];

  @override
  Future<Directory> get saveDirectory => FileManager.getJsonFormattedDirectory();
  @override
  String get targetExtension => 'json';

  @override
  bool get requiresInputFile => !_useTextInput;

  String get buttonLabel => 'Format JSON';
  
  String get _conversionTitle => 'JSON Formatter';
  String get _conversionDescription => 'Beautify and format your JSON with proper indentation.';
  IconData get _icon => Icons.code;

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (_useTextInput) {
      // Text Mode: Format text, save to temp file, return result
      final jsonContent = _jsonTextController.text.trim();
      if (jsonContent.isEmpty) {
        throw Exception('Please enter JSON content.');
      }

      final formatted = await service.formatJsonText(
        jsonContent,
        indent: _indentSize,
      );

      if (formatted == null) throw Exception('Formatting failed.');

      // Update preview
      if (mounted) {
        setState(() {
          _formattedJsonPreview = formatted;
        });
      }

      // Create temp file for the result
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'formatted_json_${DateTime.now().millisecondsSinceEpoch}.json'));
      await tempFile.writeAsString(formatted);

      return ImageToPdfResult(
        file: tempFile,
        fileName: outputName ?? 'formatted.json',
        downloadUrl: '', // Local generation, no download URL
      );

    } else {
      // File Mode
      if (file == null) throw Exception('No file selected.');

      final result = await service.formatJsonFile(
        file,
        outputFilename: outputName,
        indent: _indentSize,
      );
      
      if (result != null && mounted) {
           // Try to read for preview if small enough
           try {
             if (await result.file.length() < 1024 * 1024) {
               final content = await result.file.readAsString();
               setState(() {
                 _formattedJsonPreview = content;
               });
             } else {
               setState(() {
                 _formattedJsonPreview = null; // Too big to preview
               });
             }
           } catch (_) {}
      }
      return result;
    }
  }
  
  void _resetAll() {
    setState(() {
      _formattedJsonPreview = null;
      _jsonTextController.clear();
      resetForNewConversion(customStatus: 'Select input method to begin.');
    });
  }

  void _copyFormattedJson() {
    if (_formattedJsonPreview != null) {
      Clipboard.setData(ClipboardData(text: _formattedJsonPreview!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formatted JSON copied to clipboard!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
          _conversionTitle,
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
                  title: _conversionTitle,
                  description: _conversionDescription,
                  sourceIcon: _icon,
                  destinationIcon: Icons.format_align_left,
                ),
                const SizedBox(height: 20),
                
                _buildInputMethodToggle(),
                const SizedBox(height: 16),
                
                if (_useTextInput) ...[
                  _buildJsonTextInput(),
                  const SizedBox(height: 16),
                ] else ...[
                  ConversionActionButtonWidget(
                    isFileSelected: model.selectedFile != null,
                    onPickFile: pickFile,
                    onReset: _resetAll,
                    isConverting: model.isConverting,
                    buttonText: 'Select JSON File',
                  ),
                  const SizedBox(height: 16),
                  if (model.selectedFile != null) ...[
                    ConversionSelectedFileCardWidget(
                      fileName: p.basename(model.selectedFile!.path),
                      fileSize: formatBytes(model.selectedFile!.lengthSync()),
                      fileIcon: Icons.description,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                
                // File Name Input (Visible if File Selected OR Text Input active)
                if (_useTextInput || model.selectedFile != null) ...[
                    ConversionFileNameFieldWidget(
                      controller: fileNameController,
                      suggestedName: model.suggestedBaseName,
                      extensionLabel: '.json extension is added automatically',
                    ),
                   const SizedBox(height: 16),
                ],

                _buildIndentSelector(),
                const SizedBox(height: 20),
                
                if (_useTextInput || model.selectedFile != null)
                  ConversionConvertButtonWidget(
                    isConverting: model.isConverting,
                    onConvert: convert,
                    buttonText: buttonLabel,
                  ),
                
                const SizedBox(height: 16),
                
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                
                // Preview Area
                if (_formattedJsonPreview != null && !model.isConverting) ...[
                  const SizedBox(height: 20),
                  _buildFormattedJsonDisplay(),
                ],
                
                // Result Card (Standard Save/Share)
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
                    title: 'Formatted JSON Ready',
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

  Widget _buildInputMethodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useTextInput = false;
                  _resetAll();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_useTextInput
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      color: !_useTextInput
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upload File',
                      style: TextStyle(
                        color: !_useTextInput
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: !_useTextInput
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useTextInput = true;
                  _resetAll();
                  // Default name for text input
                   model.suggestedBaseName = 'formatted_json';
                   fileNameController.text = 'formatted_json';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _useTextInput
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: _useTextInput
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paste JSON',
                      style: TextStyle(
                        color: _useTextInput
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: _useTextInput
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.code, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Paste JSON Content',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Line numbers and text input
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                Container(
                   width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard.withOpacity(0.5),
                    border: Border(
                      right: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      _jsonTextController.text.split('\n').length.clamp(1, 30),
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _jsonTextController,
                    maxLines: 10,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Paste your JSON here...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIndentSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indentation Size',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [2, 4, 8].map((size) {
              final isSelected = _indentSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _indentSize = size),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.primaryBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$size Spaces',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedJsonDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Formatted Result:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _copyFormattedJson,
              icon: const Icon(Icons.copy, color: AppColors.primaryBlue),
              tooltip: 'Copy to Clipboard',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Darker background for code
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
          ),
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: SelectableText(
              _formattedJsonPreview ?? '',
              style: const TextStyle(
                color: Color(0xFFCE9178), // VS Code string color-ish
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
