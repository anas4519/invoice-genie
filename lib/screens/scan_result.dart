import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:invoice_scanner/constants/constants.dart';
import 'package:lottie/lottie.dart';

class ScanResult extends StatefulWidget {
  const ScanResult({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<ScanResult> createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  bool isLoading = true;
  String body = '';

  Future<void> _extractText(File file) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await _aiAnalysis(recognizedText.text);
    textRecognizer.close();
  }

  Future<void> _aiAnalysis(String text) async {
    final model = gemini.GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
    );

    String prompt = '''
    Given below is the text extracted from an Indian Tax Invoice, I need you to find thee following details from the text, if they do not exist or that field is empty, don't include it in the response. Respond in JSON format.
    Invoice number, Date, Payment Mode, Terms of Delivery, Buyer's Name, Buyer's Address, Buyer's Telephone, Buyer's GST Number, Buyer's PAN/IT. Number, State Name, Description of Goods(Name, quantity, HSN, Amount),
    Amount before GST, CGST, SGST, Total Quantity, Total Amount, CGST Applied Rate, SGST Rate, Total Tax Amount. B2B true/false (if GST number exists for buyer, B2B : True). Only include the informations asked, nothing else.

    $text
  ''';

    final content = [gemini.Content.text(prompt)];

    try {
      final result = await model.generateContent(content);
      setState(() {
        isLoading = false;
        body = result.text!;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _extractText(File(widget.imagePath));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Invoice'),
        actions: [
          IconButton(
              onPressed: () {
                _extractText(File(widget.imagePath));
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Center(
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover)),
            SizedBox(height: screenHeight * 0.02),
            if (isLoading)
              Center(
                child: Lottie.asset(
                  'assets/animations/ai-loader1.json',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  fit: BoxFit.contain,
                ),
              )
            else
              // GptMarkdown(body.substring(7, body.length - 4))
              ..._buildTextFieldsFromJson(body.substring(7, body.length - 4),
                  screenWidth, context, screenHeight)
          ],
        ),
      ),
    );
  }
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
    if (key.contains('Description of Goods') && value is List) {
      for (var item in value) {
        widgets.add(
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              border: Border.all(
                  color: isDarkMode ? Colors.grey[200]! : Colors.black,
                  width: 1),
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
                _buildTextField(
                    'Good\'s Name', item['Name'] ?? '', screenWidth),
                _buildTextField('Quantity', item['quantity']?.toString() ?? '',
                    screenWidth),
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
