import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoice_scanner/widgets/pdf_thumbnail.dart';
import 'package:invoice_scanner/services/database_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Database _database;
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
    setState(() {
      name = invoices[0]['invoice_path'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scanned Invoices'),
          centerTitle: true,
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : PDFThumbnail(pdfPath: name),
        ));
  }
}
