import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:invoice_scanner/services/database_service.dart';
import 'package:invoice_scanner/widgets/digital_invoice_row.dart';

class B2CScreen extends StatefulWidget {
  const B2CScreen({super.key});

  @override
  State<B2CScreen> createState() => _B2CScreenState();
}

class _B2CScreenState extends State<B2CScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> displayList = [];
  final TextEditingController _searchController = TextEditingController();

  void updateList(String value) {
    setState(() {
      if (value.isEmpty) {
        _initDbAndPrintInvoices();
      } else {
        displayList = displayList
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
    var invoices = await dbService.getInvoices();
    invoices = invoices.where((invoice) => invoice['b2b'] == 0).toList();
    setState(() {
      _invoices = invoices;
      displayList = List.from(_invoices.reversed);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('B2C Invoices'),
          centerTitle: true,
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : _invoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/images/b2cimage.svg', fit: BoxFit.contain,
                          width: 250,
                          height: 250,
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Text('You have not added any B2C invoices yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18))
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Container(
                            height: screenHeight * 0.07,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                              border:
                                  Border.all(color: Colors.blue, width: 1.5),
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
                                      hintText: 'Search',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Expanded(
                          child: ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  DigitalInvoiceRow(invoice: displayList[index],),
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
