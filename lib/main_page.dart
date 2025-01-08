import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:invoice_scanner/screens/b2b_screen.dart';
import 'package:invoice_scanner/screens/home_screen.dart';
import 'package:invoice_scanner/screens/b2c_screen.dart';
import 'package:invoice_scanner/screens/scan_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = [];
  int _currIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeScreen(),
      const ScanScreen(),
      const B2CScreen(),
      const B2bScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: _currIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        color: isDarkTheme? Colors.black:Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: GNav(
            onTabChange: (index) {
              setState(() {
                _currIndex = index;
              });
            },
            backgroundColor: isDarkTheme? Colors.black:Colors.grey.shade200,
            color: Colors.blue,
            activeColor: Colors.blue,
            tabBackgroundColor: Colors.grey.shade900,
            gap: screenwidth * 0.02,
            padding: EdgeInsets.all(screenwidth * 0.04),
            tabs: const [
              GButton(
                icon: CupertinoIcons.home,
                text: 'Home',
              ),
              GButton(icon: Icons.document_scanner_rounded, text: 'Scan',),
              GButton(
                icon: CupertinoIcons.group_solid,
                text: 'B2C',
              ),
              GButton(
                icon: CupertinoIcons.building_2_fill,
                text: 'B2B',
              ),
            ]
          ),
        ),
      ),
    );
  }
}