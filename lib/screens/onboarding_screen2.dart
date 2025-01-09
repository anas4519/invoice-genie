import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:invoice_scanner/main_page.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.125,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/obs1.svg',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.04),
                child: Text('Upload Invoices',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              ),
              SizedBox(height: screenHeight * 0.0),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  'You can upload an invoice image from your phone’s gallery or PDF files directly to the app. You can also take a photo, and we’ll automatically crop it for you, making it easy to store and manage your invoices with minimal effort.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenHeight * 0.05,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.grey,
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.005,
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                Container(
                  color: Colors.blue,
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.005,
                )
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          Center(
            child: SizedBox(
              width: 300, // Reduce button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background blue
                  minimumSize: Size(200, 60), // Increase height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.02), // Rounded corners (optional)
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(width: 8), // Space between text and icon
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}