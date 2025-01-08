import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class PDFRow extends StatelessWidget {
  const PDFRow({
    super.key,
    required this.invoiceNum,
    required this.filePath,
    required this.date,
  });

  final String invoiceNum;
  final String filePath;
  final String date;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        await OpenFilex.open(filePath);
      },
      child: Material(
        elevation: 4.0, // Adding elevation for shadow effect
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenWidth * 0.02),
          height: screenHeight * 0.09,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            color: Colors.blue[100],
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.135,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[700]!, width: 1.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                child: Center(
                  child: Text(
                    '.pdf',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.06),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceNum,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  Text(
                    date,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // Share the file using share_plus
                  await Share.shareXFiles(
                    [XFile(filePath)],
                    text: 'Invoice: $invoiceNum',
                  );
                },
                icon: Icon(
                  Icons.share,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
