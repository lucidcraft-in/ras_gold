// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// import 'terms.dart';

// class PrivacyPolicy extends StatefulWidget {
//   const PrivacyPolicy({super.key});

//   @override
//   State<PrivacyPolicy> createState() => _PrivacyPolicyState();
// }

// class _PrivacyPolicyState extends State<PrivacyPolicy> {
//   List<Map<String, dynamic>> userlist = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   Future<void> getData() async {
//     CollectionReference collectionReference =
//         FirebaseFirestore.instance.collection('privacyPolicy');
//     QuerySnapshot querySnapshot;

//     try {
//       querySnapshot = await collectionReference.get();
//       for (var doc in querySnapshot.docs.toList()) {
//         Map<String, dynamic> data = {
//           "id": doc.id,
//           "url": doc['name'], // URL to file
//           "fileType": doc['fileType'],
//         };
//         userlist.add(data);
//       }
//     } catch (e) {
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           iconTheme: const IconThemeData(color: Colors.black),
//           backgroundColor: Theme.of(context).primaryColor,
//           title: const Text('Privacy Policy'),
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : userlist.isEmpty
//                 ? const Center(child: Text('No data found'))
//                 : Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: userlist.length,
//                       itemBuilder: (context, index) {
//                         String fileUrl = userlist[index]['url'];

//                         return Column(
//                           children: [
//                             SizedBox(
//                               width: 200,
//                               height: 300,
//                               child: GestureDetector(
//                                 onTap: () {

//                                   if (userlist[index]['fileType'] != "pdf") {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ImageFullScreen(
//                                           imageUrl: fileUrl,
//                                         ),
//                                       ),
//                                     );
//                                   } else if (userlist[index]['fileType'] ==
//                                       "pdf") {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => PdfViewerScreen(
//                                           pdfUrl: fileUrl,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 child: userlist[index]['fileType'] != "pdf"
//                                     ? Image.network(
//                                         fileUrl,
//                                         fit: BoxFit.contain,
//                                         loadingBuilder:
//                                             (context, child, loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             return child;
//                                           }
//                                           return Center(
//                                             child: CircularProgressIndicator(
//                                               value: loadingProgress
//                                                           .expectedTotalBytes !=
//                                                       null
//                                                   ? loadingProgress
//                                                           .cumulativeBytesLoaded /
//                                                       (loadingProgress
//                                                           .expectedTotalBytes!)
//                                                   : null,
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                           return const Center(
//                                             child: Text(
//                                               'Failed to load image',
//                                               style:
//                                                   TextStyle(color: Colors.red),
//                                             ),
//                                           );
//                                         },
//                                       )
//                                     : const Center(
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Icon(Icons.picture_as_pdf,
//                                                 size: 50, color: Colors.red),
//                                             SizedBox(height: 10),
//                                             Text(
//                                               'Open PDF',
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ));
//   }
// }

// class PdfViewerScreen extends StatelessWidget {
//   final String pdfUrl;

//   const PdfViewerScreen({super.key, required this.pdfUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("PDF Viewer"),
//         backgroundColor: Colors.black,
//       ),
//       body: const PDF().cachedFromUrl(
//         pdfUrl,
//         placeholder: (progress) =>
//             Center(child: CircularProgressIndicator(value: progress / 100)),
//         errorWidget: (error) => const Center(
//             child: Text("Failed to load PDF",
//                 style: TextStyle(color: Colors.red))),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'terms.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  List<Map<String, dynamic>> userlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('privacyPolicy');

      QuerySnapshot querySnapshot = await collectionReference.get();

      userlist.clear();

      for (var doc in querySnapshot.docs) {
        userlist.add({
          "id": doc.id,
          "url": doc['name'],
          "fileType": doc['fileType'],
        });
      }
    } catch (e) {
      debugPrint("Privacy Policy Error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

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
          "Privacy Policy",
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : userlist.isEmpty
              ? _emptyState()
              : _documentList(),
    );
  }

  Widget _documentList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: userlist.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = userlist[index];

        final String fileUrl = item['url'];
        final bool isPdf = item['fileType'].toString().toLowerCase() == "pdf";

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isPdf) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerScreen(
                    pdfUrl: fileUrl,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageFullScreen(
                    imageUrl: fileUrl,
                  ),
                ),
              );
            }
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
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isPdf
                        ? const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 38,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              fileUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                color: _gold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPdf ? "Privacy Policy PDF" : "Privacy Policy Image",
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isPdf ? "Tap to open PDF" : "Tap to view image",
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: _gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
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
          "No Privacy Policy Found",
          style: TextStyle(
            color: _muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "PDF Viewer",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(
          child: CircularProgressIndicator(
            value: progress / 100,
          ),
        ),
        errorWidget: (error) => const Center(
          child: Text(
            "Failed to load PDF",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
