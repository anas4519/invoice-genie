import 'package:flutter/material.dart';
import 'package:invoice_scanner/widgets/pdf_thumbnail.dart';
import 'package:invoice_scanner/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  bool isLoading = true;
  @override
  void initState() {
    _initDbAndPrintInvoices();
    super.initState();
  }

  Future<void> _initDbAndPrintInvoices() async {
    final dbService = DataBaseService();
    final invoices = await dbService.getInvoices();
    print(invoices[0]['goods_description']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scanned Invoices'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Hello'),
        ));
  }
}
