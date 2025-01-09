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
  List<Map<String, dynamic>> goodsDescription = [];

  void _parseGoodsDescription() {
    final goodsListString = widget.invoice['goods_description'] as String?;
    if (goodsListString == null) return;

    // Split the string into individual items
    final items = goodsListString.split('}, {');

    goodsDescription = items.map((item) {
      // Clean up the string
      item = item.replaceAll('{', '').replaceAll('}', '').trim();

      // Split into key-value pairs
      final pairs = item.split(', ');

      // Convert to Map
      final map = <String, dynamic>{};
      for (var pair in pairs) {
        final parts = pair.split(': ');
        if (parts.length == 2) {
          final key = parts[0].trim();
          var value = parts[1].trim();

          map[key] = value;
        }
      }
      return map;
    }).toList();

    setState(() {});
  }

  Future<void> _loadPDF() async {
    try {
      final path = widget.invoice['invoice_path'] as String?;
      if (path == null) {
        setState(() => isLoading = false);
        return;
      }

      final document = await PDFDocument.fromFile(File(path));
      doc = document;
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildDetailColumn(String label, String? value) {
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
            value ?? 'Not Available',
            style: const TextStyle(height: 1.5, color: Colors.black),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null) return;

    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  String? _getValue(String key) {
    return widget.invoice[key]?.toString();
  }

  @override
  void initState() {
    _loadPDF();
    _parseGoodsDescription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getValue('buyers_name') ?? 'Invoice Details',
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
                      : const Center(
                          child: Text(
                            'Failed to load the document.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
            SizedBox(height: screenHeight * 0.05),
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
                  Center(
                    child: const Text(
                      'Buyer Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailColumn('Buyer\'s Name', _getValue('buyers_name')),
                  const Divider(color: Colors.blue),
                  if (_getValue('buyers_address') != null) ...[
                    _buildDetailColumn(
                        'Buyer\'s Address', _getValue('buyers_address')),
                    const Divider(color: Colors.blue),
                  ],
                  if (_getValue('buyers_gst_num') != null) ...[
                    _buildDetailColumn(
                        'GST Number', _getValue('buyers_gst_num')),
                    const Divider(color: Colors.blue),
                  ],
                  if (_getValue('buyers_telephone') != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailColumn(
                            'Phone Number', _getValue('buyers_telephone')),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              _makePhoneCall(_getValue('buyers_telephone')),
                          icon: const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.blue),
                  ],
                  if (_getValue('buyers_pan') != null) ...[
                    _buildDetailColumn('PAN/IT No.', _getValue('buyers_pan')),
                    const Divider(color: Colors.blue),
                  ],
                  _buildDetailColumn('State', _getValue('state_name')),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
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
                  Center(
                    child: const Text(
                      'Invoice Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailColumn(
                      'Invoice Number', _getValue('invoice_num')),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn('Date', _getValue('date')),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Mode of Payment', _getValue('payment_mode')),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Terms of Delivery', _getValue('terms_of_delivery')),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Text('Description of Goods (${_getValue('total_quantity') ?? "0"})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            SizedBox(height: screenHeight * 0.005),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: goodsDescription.map((item) {
                return Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailColumn('Name', item['Name']?.toString()),
                      const Divider(color: Colors.green),
                      _buildDetailColumn(
                          'Quantity', item['quantity']?.toString()),
                      const Divider(color: Colors.green),
                      _buildDetailColumn('HSN', item['HSN']?.toString()),
                      const Divider(color: Colors.green),
                      _buildDetailColumn('Amount', item['Amount']?.toString()),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.04),
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
                  Center(
                    child: const Text('Taxes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black)),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailColumn('CGST Rate (%)', _getValue('cgst_rate')),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn('SGST Rate (%)', _getValue('sgst_rate')),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'CGST Amount',
                      _getValue('cgst') != null
                          ? '₹${_getValue('cgst')}'
                          : null),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'SGST Amount',
                      _getValue('sgst') != null
                          ? '₹${_getValue('sgst')}'
                          : null),
                  const Divider(color: Colors.blue),
                  _buildDetailColumn(
                      'Total Tax Amount',
                      _getValue('total_tax_amount') != null
                          ? '₹${_getValue('total_tax_amount')}'
                          : null),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text('Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black)),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailColumn(
                      'Net Amount',
                      _getValue('amount_before_gst') != null
                          ? '₹${_getValue('amount_before_gst')}'
                          : null),
                  const Divider(color: Colors.red),
                  _buildDetailColumn(
                      'Total Amount',
                      _getValue('total_amount') != null
                          ? '₹${_getValue('total_amount')}'
                          : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
