import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:raz_gold/common/colo_extension.dart';

class BrochureScreen extends StatefulWidget {
  const BrochureScreen({super.key});

  @override
  State<BrochureScreen> createState() => _BrochureScreenState();
}

class _BrochureScreenState extends State<BrochureScreen> {
  String? pdfUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBrochure();
  }

  Future<void> fetchBrochure() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('brochure')
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          pdfUrl = docSnapshot['name']; // Fetch URL
          isLoading = false;
        });
      } else {
        setState(() {
          pdfUrl = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        pdfUrl = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: TColo.primaryColor1,
          title: const Text('Company Brochure')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : pdfUrl != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                      const SizedBox(height: 10),
                      const Text('View Our Latest Brochure',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: TColo.primaryColor2),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfViewerScreen(pdfUrl: pdfUrl!),
                            ),
                          );
                        },
                        child: const Text("Open Brochure"),
                      ),
                    ],
                  )
                : const Text('No brochure available'),
      ),
    );
  }
}

// PDF Viewer Screen
class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: TColo.primaryColor1, title: const Text("PDF Viewer")),
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
