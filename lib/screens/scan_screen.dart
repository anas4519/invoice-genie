import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
    HapticFeedback.mediumImpact();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
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
    HapticFeedback.mediumImpact();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.04,
            ),
            Center(
              child: SvgPicture.asset(
                'assets/images/scanScreen.svg',
                fit: BoxFit.contain,
                height: 200,
                width: 200,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.04,
            ),
            Center(
                child: Text(
              'Click one of the buttons to start scanning!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: screenHeight * 0.1,
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: screenHeight * 0.01,
                    children: [
                      ElevatedButton(
                        onPressed: _openScanner,
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(24),
                            elevation: 3),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          size: 50,
                        ),
                      ),
                      Text(
                        'Click/Upload Image',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                  Column(
                    spacing: screenHeight * 0.01,
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickPDF(context),
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(24),
                            elevation: 3),
                        child: const Icon(
                          CupertinoIcons.folder_fill,
                          size: 50,
                        ),
                      ),
                      Text(
                        'Upload File',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
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
