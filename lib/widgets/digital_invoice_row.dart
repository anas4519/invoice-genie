import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoice_scanner/screens/digital_invoice.dart';

class DigitalInvoiceRow extends StatelessWidget {
  const DigitalInvoiceRow({super.key, required this.invoice});
  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.04, right: screenWidth * 0.04),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.065,
                width: screenWidth * 0.14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  color: Colors.blue[100],
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.fileInvoice,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.04,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.55, // Adjust this value as needed
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['buyers_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        invoice['invoice_num'],
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        invoice['total_quantity'].toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: screenWidth * 0.2,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => DigitalInvoice(invoice: invoice),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.blue,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice['date'],
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}