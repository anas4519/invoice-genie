import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfCreator {
  static Future<File> createPdfFromImages(List<String> imagePaths) async {
    final pdf = pw.Document();

    for (String imagePath in imagePaths) {
      final image = pw.MemoryImage(
        File(imagePath).readAsBytesSync(),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    final outputDirectory = await getApplicationDocumentsDirectory();
    final file = File('${outputDirectory.path}/output.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
