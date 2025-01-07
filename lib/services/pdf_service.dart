import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfStorageService {
  Future<String> _getAppDocumentPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> savePdfToAppDirectory(File pdfFile) async {
    try {
      final appDocDir = await _getAppDocumentPath();
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final filePath = '$appDocDir/$fileName';
      
      await pdfFile.copy(filePath);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }
}
