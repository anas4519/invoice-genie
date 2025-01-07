import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';

class PDFThumbnail extends StatelessWidget {
  final String pdfPath;
  final double width;
  final double height;
  final BoxFit fit;

  const PDFThumbnail({
    super.key,
    required this.pdfPath,
    this.width = 150,
    this.height = 150,
    this.fit = BoxFit.cover,
  });

  Future<ImageProvider> _getImageProvider() async {
    try {
      final document = await PdfDocument.openFile(pdfPath);
      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: width.toInt() * 2, // Render at 2x for better quality
        height: height.toInt() * 2,
      );
      return MemoryImage(pageImage.pixels);
    } catch (e) {
      throw Exception('Failed to load PDF thumbnail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: _getImageProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print(snapshot);
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.grey,
            ),
          );
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: snapshot.data!,
              fit: fit,
            ),
          ),
        );
      },
    );
  }
}