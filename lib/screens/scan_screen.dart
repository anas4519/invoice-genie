import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invoice_scanner/screens/pdf_scan_result.dart';
import 'package:invoice_scanner/screens/scan_result.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<String> _pictures = [];

  Future<void> _pickPDF(BuildContext context) async {
    // Open file picker and allow only PDF files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // If a file is selected
    if (result != null) {
      // Get the file path
      String? filePath = result.files.single.path;

      if (filePath != null) {
        // Navigate to the PDF preview screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfScanResult(filePath: filePath),
          ),
        );
      }
    }
  }

  void _openScanner() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures(
              isGalleryImportAllowed: true) ??
          [];
      if (!mounted) return;
      _pictures = pictures;
      if (_pictures.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ScanResult(
                  images: _pictures,
                )));
      }
    } catch (exception) {
      // Handle exception here
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Invoice'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.04,
            ),
            Image.asset(
              'assets/images/Group 2@2x.png',
              width: screenWidth * 0.85,
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Center(
                child: Text(
              'Click one of the buttons to start scanning',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _openScanner,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      elevation: 3
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 50,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickPDF(context),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(24),
                      elevation: 3
                    ),
                    child: const Icon(
                      CupertinoIcons.folder_fill,
                      size: 50,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
