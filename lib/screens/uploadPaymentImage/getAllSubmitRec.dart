// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../../providers/paymentBill.dart';
// import 'singleView.dart';

// class submittedRec extends StatefulWidget {
//   const submittedRec({super.key, required this.userId});
//   final String userId;

//   @override
//   State<submittedRec> createState() => _submittedRecState();
// }

// class _submittedRecState extends State<submittedRec> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: AppBar(
//         title: const Text('Submitted Screenshot'),
//         iconTheme: const IconThemeData(color: Colors.black),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: Provider.of<PaymentBillProvider>(context, listen: false)
//             .getAllData(widget.userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return const Center(child: Text('Something Error Occured'));
//           } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No data found'));
//           } else {
//             var documents = snapshot.data!.docs;

//             return Padding(
//               padding: const EdgeInsets.all(0.0),
//               child: ListView.separated(
//                 separatorBuilder: (context, index) {
//                   return SizedBox(
//                     height: 2,
//                     width: MediaQuery.of(context).size.width * .7,
//                   );
//                 },
//                 itemCount: documents.length,
//                 itemBuilder: (context, index) {
//                   var data = documents[index].data() as Map<String, dynamic>;
//                   var document = documents[index];
//                   // Convert Timestamp to DateTime
//                   DateTime dateTime = (data['date'] as Timestamp).toDate();

//                   // Format the date and time
//                   String formattedDate =
//                       DateFormat('dd MMM yyyy').format(dateTime);
//                   String formattedTime =
//                       DateFormat('HH:mm:ss').format(dateTime);
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Icon(Icons.screenshot),
//                                 SizedBox(
//                                     width:
//                                         MediaQuery.of(context).size.width * .6,
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     SingleViewPayment(
//                                                       documentId: document.id,
//                                                     )));
//                                       },
//                                       tileColor:
//                                           const Color.fromARGB(255, 244, 231, 214),
//                                       title: Text(
//                                           data['amount'].toString() ?? '0'),
//                                       subtitle: Text(
//                                           data['note'] ?? 'No Description'),
//                                     )),
//                                 Expanded(
//                                   child: Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 12,
//                                         // backgroundColor:
//                                         //     const Color.fromARGB(67, 76, 175, 79),
//                                         backgroundColor: data['status'] ==
//                                                 "Request"
//                                             ? const Color.fromARGB(77, 244, 67, 54)
//                                             : const Color.fromARGB(66, 76, 175, 79),

//                                         child: CircleAvatar(
//                                           radius: 5,
//                                           backgroundColor: data['status'] ==
//                                                   "Request"
//                                               ? const Color.fromARGB(255, 199, 48, 37)
//                                               : Colors.green,
//                                         ),
//                                       ),
//                                       Text(data['status'] == "Request"
//                                           ? "Pending"
//                                           : "Approved")
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   formattedDate,
//                                   style: const TextStyle(
//                                       color: Color.fromARGB(255, 38, 18, 18),
//                                       fontSize: 11),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );

//                   // ListTile(
//                   //   onTap: () {
//                   //     print("----666666--");
//                   //     print(document);
//                   //     Navigator.push(
//                   //         context,
//                   //         MaterialPageRoute(
//                   //             builder: (context) => SingleViewPayment(
//                   //                   documentId: document.id,
//                   //                 )));
//                   //   },
//                   //   tileColor: Color.fromARGB(255, 244, 231, 214),
//                   //   title: Text(data['amount'].toString() ?? '0'),
//                   //   subtitle: Text(data['note'] ?? 'No Description'),
//                   //   trailing: Column(
//                   //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   //     children: [
//                   //       CircleAvatar(
//                   //         radius: 12,
//                   //         // backgroundColor:
//                   //         //     const Color.fromARGB(67, 76, 175, 79),
//                   //         backgroundColor: data['status'] == "Request"
//                   //             ? Color.fromARGB(77, 244, 67, 54)
//                   //             : Color.fromARGB(66, 76, 175, 79),

//                   //         child: CircleAvatar(
//                   //           radius: 5,
//                   //           backgroundColor: data['status'] == "Request"
//                   //               ? Color.fromARGB(255, 199, 48, 37)
//                   //               : Colors.green,
//                   //         ),
//                   //       ),
//                   //       Text(data['status'] == "Request"
//                   //           ? "Waiting for Approval"
//                   //           : "Approved")
//                   //     ],
//                   //   ),
//                   // );
//                 },
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/paymentBill.dart';
import 'singleView.dart';

class SubmittedRec extends StatefulWidget {
  const SubmittedRec({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<SubmittedRec> createState() => _SubmittedRecState();
}

class _SubmittedRecState extends State<SubmittedRec> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
        title: const Text(
          "Submitted Receipts",
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<PaymentBillProvider>(
          context,
          listen: false,
        ).getAllData(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
                child: const Text(
                  "No receipts found",
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = documents[index];

              final data = document.data() as Map<String, dynamic>;

              final DateTime dateTime = (data['date'] as Timestamp).toDate();

              final String formattedDate =
                  DateFormat('dd MMM yyyy').format(dateTime);

              final bool isPending = data['status'] == "Request";

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SingleViewPayment(
                        documentId: document.id,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _line),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: _gold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹ ${data['amount'] ?? 0}",
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['note'] ?? "No description",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? const Color(0xFFFFF0EE)
                                    : const Color(0xFFEAF7EC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isPending ? "Pending" : "Approved",
                                style: TextStyle(
                                  color: isPending ? Colors.red : Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: _gold,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
