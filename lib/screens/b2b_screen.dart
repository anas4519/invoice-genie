import 'package:flutter/material.dart';

class B2bScreen extends StatefulWidget {
  const B2bScreen({super.key});

  @override
  State<B2bScreen> createState() => _B2bScreenState();
}

class _B2bScreenState extends State<B2bScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('B2B Invoices'),
      ),
      body: Center(
        child: Text('B2B'),
      ),
    );
  }
}
