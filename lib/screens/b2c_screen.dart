import 'package:flutter/material.dart';

class B2CScreen extends StatelessWidget {
  const B2CScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('B2C Invoices'),
      ),
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}