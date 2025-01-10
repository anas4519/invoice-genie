import 'dart:convert';
import 'dart:io';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:invoice_scanner/constants/constants.dart';
import 'package:invoice_scanner/main_page.dart';
import 'package:invoice_scanner/services/database_service.dart';
import 'package:invoice_scanner/services/pdf_service.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;

class PdfScanResult extends StatefulWidget {
  const PdfScanResult({super.key, required this.filePath});
  final String filePath;

  @override
  State<PdfScanResult> createState() => _PdfScanResultState();
}

class _PdfScanResultState extends State<PdfScanResult> {
  PDFDocument? doc;
  bool isLoading = true;
  bool isAiLoading = true;
  String body = '';
  late PdfStorageService _pdfStorageService;
  late DataBaseService dataBaseService;

  @override
  void initState() {
    super.initState();
    _loadPDF();
    _extractText();
    _pdfStorageService = PdfStorageService();
    dataBaseService = DataBaseService();
  }

  Future<void> _loadPDF() async {
    try {
      final document = await PDFDocument.fromFile(File(widget.filePath));
      doc = document;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _extractText() async {
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData(widget.filePath));

    PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();
    await _aiAnalysis(text);
  }

  Future<List<int>> _readDocumentData(String filePath) async {
    File file = File(filePath);
    return await file.readAsBytes();
  }

  Future<void> _aiAnalysis(String text) async {
    final model = gemini.GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: GEMINI_API_KEY,
    );

    String prompt = '''
    Given below is the text extracted from an Indian Tax Invoice, I need you to find thee following details from the text, if they do not exist or that field is empty, don't include it in the response. Respond in JSON format.
    Invoice number, Date, Payment Mode, Terms of Delivery, Buyer's Name, Buyer's Address, Buyer's Telephone, Buyer's GST Number, Buyer's PAN/IT. Number, State Name, Description of Goods(Name, quantity, HSN, Amount),
    Amount before GST, CGST, SGST, Total Quantity, Total Amount, CGST Rate, SGST Rate, Total Tax Amount. B2B true/false (if GST number exists for buyer, B2B : True). Only include the informations asked, nothing else. In the last key (Feedback), give a string that contains information on whether the total tax rates applied (CGST+SGST) for the given HSN numbers are correct.

    $text
  ''';

    final content = [gemini.Content.text(prompt)];

    try {
      final result = await model.generateContent(content);
      print(result.text);
      setState(() {
        isAiLoading = false;
        body = result.text!;
      });
    } catch (e) {
      setState(() {
        isAiLoading = false;
      });
    }
  }

  Future<void> _saveInvoice() async {
    try {
      // Load the PDF file from the provided file path
      File pdfFile = File(widget.filePath);

      // Save the PDF file to the app's document directory
      String savedFilePath =
          await _pdfStorageService.savePdfToAppDirectory(pdfFile);

      // Now you can add the new invoice to the database
      await _addInvoiceToDatabase(savedFilePath);
    } catch (e) {
      print('Failed to save and add invoice: $e');
    }
  }

  String getGoodsDescription(Map<String, dynamic> data) {
    if (data.containsKey('Description of Goods')) {
      return data['Description of Goods'].toString();
    } else if (data
        .containsKey('Description of Goods(Name, quantity, HSN, Amount)')) {
      return data['Description of Goods(Name, quantity, HSN, Amount)']
          .toString();
    } else if (data
        .containsKey('Description of Goods(Name, Quantity, HSN, Amount)')) {
      return data['Description of Goods(Name, Quantity, HSN, Amount)']
          .toString();
    } else {
      return '';
    }
  }

  Future<void> _addInvoiceToDatabase(String filePath) async {
    final invoiceData = jsonDecode(body.substring(7, body.length - 4));
    final s = getGoodsDescription(invoiceData);

    final invoice = {
      'invoice_num': invoiceData['Invoice number'],
      'date': invoiceData['Date'],
      'payment_mode': invoiceData['Payment Mode'],
      'terms_of_delivery': invoiceData['Terms of Delivery'],
      'buyers_name': invoiceData['Buyer\'s Name'],
      'buyers_address': invoiceData['Buyer\'s Address'],
      'buyers_telephone': invoiceData['Buyer\'s Telephone'],
      'buyers_gst_num': invoiceData['Buyer\'s GST Number'],
      'buyers_pan': invoiceData['Buyer\'s PAN/IT. Number'],
      'state_name': invoiceData['State Name'],
      'goods_description': s.substring(1, s.length - 1),
      'amount_before_gst': invoiceData['Amount before GST'],
      'cgst': invoiceData['CGST'],
      'sgst': invoiceData['SGST'],
      'total_quantity': invoiceData['Total Quantity'],
      'total_amount': invoiceData['Total Amount'],
      'cgst_rate': invoiceData['CGST Rate'],
      'sgst_rate': invoiceData['SGST Rate'],
      'total_tax_amount': invoiceData['Total Tax Amount'],
      'invoice_path': filePath,
      'b2b': invoiceData['B2B'].toString().toLowerCase() == 'false' ? 0 : 1
    };

    await dataBaseService.insertInvoice(invoice);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Invoice Saved Successfully')));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Invoice'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.6,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : doc != null
                      ? PDFViewer(
                          document: doc!,
                          showNavigation: false,
                        )
                      : Center(
                          child: Text(
                            'Failed to load the document.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (isAiLoading)
              Center(
                child: Lottie.asset(
                  'assets/animations/ai-loader1.json',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  fit: BoxFit.contain,
                ),
              )
            else
              Column(
                children: [
                  ..._buildTextFieldsFromJson(
                      body.substring(7, body.length - 4),
                      screenWidth,
                      context,
                      screenHeight),
                  ElevatedButton(
                    onPressed: _saveInvoice,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02))),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Text(
                        'Add Invoice',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }

  List<Widget> _buildTextFieldsFromJson(String jsonResponse, double screenWidth,
      BuildContext context, double screenHeight) {
    final Map<String, dynamic> data = jsonDecode(jsonResponse);
    List<Widget> widgets = [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    data.forEach((key, value) {
      if (key.contains('Feedback')) {
        widgets.insert(0, GptMarkdown(value.toString()));
        widgets.insert(
            1,
            SizedBox(
              height: screenHeight * 0.04,
            ));
            
      }
      else if (key.contains('Description of Goods') && value is List) {
        for (var item in value) {
          widgets.add(
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(
                    color: isDarkMode ? Colors.grey[200]! : Colors.black,
                    width: 2),
              ),
              child: Column(
                spacing: screenHeight * 0.02,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Item',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  _buildTextField('Item Name', item['Name'] ?? '', screenWidth),
                  _buildTextField('Quantity',
                      item['quantity']?.toString() ?? '', screenWidth),
                  _buildTextField(
                      'HSN', item['HSN']?.toString() ?? '', screenWidth),
                  _buildTextField(
                      'Amount', item['Amount']?.toString() ?? '', screenWidth),
                ],
              ),
            ),
          );
          widgets.add(SizedBox(
            height: screenHeight * 0.02,
          ));
        }
      } else if (value != null) {
        widgets.add(_buildTextField(key, value.toString(), screenWidth));
        widgets.add(SizedBox(height: screenHeight * 0.02));
      }
    });

    return widgets;
  }
}
