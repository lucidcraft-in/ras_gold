import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final String status;
  final String paymentId;
  final String orderId;
  final String signature;

  const ReceiptPage(
      {super.key, required this.status,
      required this.paymentId,
      required this.orderId,
      required this.signature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Payment ID: $paymentId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Order ID: $orderId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Signature: $signature', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
