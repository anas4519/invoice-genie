import 'package:flutter/material.dart';
import 'package:invoice_scanner/services/database_service.dart';
import 'package:invoice_scanner/widgets/pdf_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> _invoices = [];
  final TextEditingController _searchController = TextEditingController();

  void updateList(String value) {
    setState(() {
      if (value.isEmpty) {
        _initDbAndPrintInvoices();
      } else {
        _invoices = _invoices
            .where((invoice) =>
                invoice['invoice_num']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                invoice['date']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                invoice['buyers_name']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                invoice['payment_mode']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    _initDbAndPrintInvoices();
    super.initState();
  }

  Future<void> _initDbAndPrintInvoices() async {
    final dbService = DataBaseService();
    final invoices = await dbService.getInvoices();
    setState(() {
      _invoices = invoices;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Scanned Invoices'),
          centerTitle: true,
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Container(
                        height: screenHeight * 0.07,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(color: Colors.blue, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search_rounded,
                                color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                onChanged: (value) => updateList(value),
                                controller: _searchController,
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search an invoice',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // PDFRow(date: _invoices[0]['date'], filePath: _invoices[0]['invoice_path'], invoiceNum: _invoices[0]['invoice_num'],)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _invoices.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              PDFRow(
                                  invoiceNum: _invoices[index]['invoice_num'],
                                  filePath: _invoices[index]['invoice_path'],
                                  date: _invoices[index]['date']),
                              SizedBox(
                                height: screenHeight * 0.01,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ));
  }
}
