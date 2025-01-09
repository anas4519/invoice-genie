import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DigitalInvoice extends StatefulWidget {
  const DigitalInvoice({super.key, required this.invoice});
  final Map<String, dynamic> invoice;

  @override
  State<DigitalInvoice> createState() => _DigitalInvoiceState();
}

class _DigitalInvoiceState extends State<DigitalInvoice> {
  bool isLoading = true;
  PDFDocument? doc;

  Future<void> _loadPDF() async {
    try {
      final document =
          await PDFDocument.fromFile(File(widget.invoice['invoice_path']));
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

  Widget _buildDetailColumn(String label, String value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(height: 1.5, color: Colors.black),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    _loadPDF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoice['buyers_name'],
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text('Buyer Details', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28
            ),),
            SizedBox(height: screenHeight*0.005,),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center(
                  //   child: Text('Buyer Details'),
                  // ),
                  _buildDetailColumn(
                      'Buyer\'s Name', widget.invoice['buyers_name']),
                  const Divider(color: Colors.blue),
                  if (widget.invoice['buyers_address'] != null) ...[
                    _buildDetailColumn(
                        'Buyer\'s Address', widget.invoice['buyers_address']),
                    const Divider(color: Colors.blue),
                  ],
                  if (widget.invoice['buyers_gst_num'] != null) ...[
                    _buildDetailColumn(
                        'GST Number', widget.invoice['buyers_gst_num']),
                    const Divider(color: Colors.blue),
                  ],
                  if (widget.invoice['buyers_telephone'] != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailColumn(
                            'Phone Number', widget.invoice['buyers_telephone']),
                        Spacer(),
                        IconButton(
                          onPressed: () => _makePhoneCall(
                              widget.invoice['buyers_telephone']),
                          icon: const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.blue),
                  ],
                  if (widget.invoice['buyers_pan'] != null) ...[
                    _buildDetailColumn(
                        'PAN/IT No.', widget.invoice['buyers_pan']),
                    const Divider(color: Colors.blue),
                  ],
                  _buildDetailColumn('State', widget.invoice['state_name']),

                  // _buildDetailColumn(
                  //     'Invoice Number', widget.invoice['invoice_num']),
                  // const Divider(color: Colors.blue),
                  // _buildDetailColumn('Date', widget.invoice['date']),
                  // const Divider(color: Colors.blue),
                  // _buildDetailColumn(
                  //     'Mode of Payment', widget.invoice['payment_mode']),
                  // const Divider(color: Colors.blue),
                  // _buildDetailColumn(
                  //     'Terms of Delivery', widget.invoice['terms_of_delivery']),
                  // const Divider(color: Colors.blue),
                ],
              ),
            ),
            SizedBox(height: screenHeight*0.04,),
            Text('Invoice Details', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28
            ),),
            SizedBox(height: screenHeight*0.005,),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 

                  _buildDetailColumn(
                      'Invoice Number', widget.invoice['invoice_num']),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn('Date', widget.invoice['date']),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Mode of Payment', widget.invoice['payment_mode']),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Terms of Delivery', widget.invoice['terms_of_delivery']),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Decription of Goods', widget.invoice['goods_description']),
                  const Divider(color: Colors.blue),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
