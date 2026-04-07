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
  List<Map<String, dynamic>> userlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('privacyPolicy');
    QuerySnapshot querySnapshot;

    try {
      querySnapshot = await collectionReference.get();
      for (var doc in querySnapshot.docs.toList()) {
        Map<String, dynamic> data = {
          "id": doc.id,
          "url": doc['name'], // URL to file
          "fileType": doc['fileType'],
        };
        userlist.add(data);
      }
    } catch (e) {
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Privacy Policy'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userlist.isEmpty
                ? const Center(child: Text('No data found'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userlist.length,
                      itemBuilder: (context, index) {
                        String fileUrl = userlist[index]['url'];

                        return Column(
                          children: [
                            SizedBox(
                              width: 200,
                              height: 300,
                              child: GestureDetector(
                                onTap: () {

                                  if (userlist[index]['fileType'] != "pdf") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageFullScreen(
                                          imageUrl: fileUrl,
                                        ),
                                      ),
                                    );
                                  } else if (userlist[index]['fileType'] ==
                                      "pdf") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                          pdfUrl: fileUrl,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: userlist[index]['fileType'] != "pdf"
                                    ? Image.network(
                                        fileUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                          .expectedTotalBytes!)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Text(
                                              'Failed to load image',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.picture_as_pdf,
                                                size: 50, color: Colors.red),
                                            SizedBox(height: 10),
                                            Text(
                                              'Open PDF',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ));
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        backgroundColor: Colors.black,
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) =>
            Center(child: CircularProgressIndicator(value: progress / 100)),
        errorWidget: (error) => const Center(
            child: Text("Failed to load PDF",
                style: TextStyle(color: Colors.red))),
      ),
    );
  }
}
