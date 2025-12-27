import '../app_modules/imports_module.dart';

class ConversionModel {
  File? selectedFile;
  ImageToPdfResult? conversionResult;
  bool isConverting = false;
  bool isSaving = false;
  bool fileNameEdited = false;
  String statusMessage;
  String? suggestedBaseName;
  String? savedFilePath;

  ConversionModel({
    this.selectedFile,
    this.conversionResult,
    this.isConverting = false,
    this.isSaving = false,
    this.fileNameEdited = false,
    required this.statusMessage,
    this.suggestedBaseName,
    this.savedFilePath,
  });

  void reset({required String defaultStatusMessage}) {
    selectedFile = null;
    conversionResult = null;
    isConverting = false;
    isSaving = false;
    fileNameEdited = false;
    statusMessage = defaultStatusMessage;
    suggestedBaseName = null;
    savedFilePath = null;
  }
}
