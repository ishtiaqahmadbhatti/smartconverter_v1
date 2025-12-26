import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../widgets/persistent_result_card.dart';
import '../../../widgets/conversion_status_display.dart';
import '../../../widgets/conversion_result_save_card.dart';
import '../../../widgets/conversion_header_card.dart';
import '../../../widgets/conversion_action_buttons.dart';
import '../../../widgets/conversion_selected_file_card.dart';
import '../../../widgets/conversion_file_name_field.dart';
import '../../../widgets/conversion_convert_button.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';
import '../../../models/conversion_model.dart';
import '../../../mixins/text_conversion_mixin.dart';

class PdfToTextTextPage extends StatefulWidget {
  const PdfToTextTextPage({super.key});

  @override
  State<PdfToTextTextPage> createState() => _PdfToTextTextPageState();
}

class _PdfToTextTextPageState extends State<PdfToTextTextPage> 
    with AdHelper, TextConversionMixin {
  
  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a PDF file to begin.',
  );

  @override
  String get fileTypeLabel => 'PDF';
  
  @override
  List<String> get allowedExtensions => ['pdf'];
  
  @override
  String get conversionToolName => 'Pdf-to-Text'; // Match existing if strict, or use consistent name
  
  @override
  Future<Directory> get saveDirectory => FileManager.getPdfToTextDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    fileNameController
      ..removeListener(handleFileNameChange)
      ..dispose();
    super.dispose();
  }
  
  @override
  Future<ImageToPdfResult?> performConversion(File file, String? outputName) {
    return service.convertPdfToText(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Text', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConversionHeaderCard(
                      title: 'PDF to Text',
                      description: 'Extract text from PDF documents',
                      iconSource: Icons.picture_as_pdf,
                      iconTarget: Icons.text_fields,
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtons(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select PDF File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCard(
                        fileName: p.basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.picture_as_pdf,
                      ),
                      const SizedBox(height: 16),
                      ConversionFileNameField(
                        controller: fileNameController,
                      ),
                      const SizedBox(height: 24),
                      ConversionConvertButton(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        buttonText: 'Convert to Text',
                        isEnabled: !model.isConverting,
                      ),
                      const SizedBox(height: 24),
                    ],

                    ConversionStatusDisplay(
                        message: model.statusMessage,
                        isConverting: model.isConverting,
                        isSuccess: model.conversionResult != null,
                    ),
                    
                    if (model.conversionResult != null) ...[
                      const SizedBox(height: 20),
                      if (model.savedFilePath == null)
                        ConversionResultSaveCard(
                          fileName: model.conversionResult!.fileName,
                          isSaving: model.isSaving,
                          onSave: saveResult,
                          title: 'Text File Ready', 
                        )
                      else
                        PersistentResultCard(
                            savedFilePath: model.savedFilePath!,
                            onShare: shareTextFile,
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
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
