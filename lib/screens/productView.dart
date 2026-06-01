// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/product.dart';

class SwapableProductView extends StatefulWidget {
  const SwapableProductView({super.key, this.category});
  final String? category;

  @override
  State<SwapableProductView> createState() => _SwapableProductViewState();
}

class _SwapableProductViewState extends State<SwapableProductView> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  late String categoryName;
  List productList = [];
  Map<String, dynamic> aboutUsData = {};

  Future<void> getCategory() async {
    setState(() {
      categoryName = widget.category ?? 'Unknown Category';
    });

    var db = Product();
    db.initiliase();
    db.read(categoryName).then((value) {
      if (!mounted) return;
      setState(() {
        productList = value ?? [];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCategory();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('aboutUs').limit(1).get();

      if (!mounted || querySnapshot.docs.isEmpty) return;
      var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        aboutUsData = data;
      });
    } catch (e) {
      debugPrint("Error loading contact details: $e");
    }
  }

  void _launchWhatsApp(var product) async {
    String phone = "91${aboutUsData["phone"] ?? aboutUsData["whatsapp"] ?? ""}";
    String message = '''
Hello, I am interested in the following product:

Product Name: ${product['productName']}
Product Code: ${product['productCode']}
Gram: ${product['gram']}g
Category: ${product['category']}

Please provide more details. Thank you!
''';

    String whatsappUrl =
        "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";

    try {
      final Uri url = Uri.parse(whatsappUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
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
        title: Text(
          categoryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: productList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : PageView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return _productPage(product, index);
              },
            ),
    );
  }

  Widget _productPage(dynamic product, int index) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.46,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .045),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product["photo"] ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(FontAwesomeIcons.gem, color: _gold, size: 42),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product["productName"] ?? 'Gold Product',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}/${productList.length}',
                            style: const TextStyle(
                              color: _deepGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(Icons.confirmation_number_outlined, "Code",
                        product["productCode"]),
                    _buildDetailRow(Icons.scale_outlined, "Weight",
                        _formatWeight(product["gram"])),
                    _buildDetailRow(Icons.category_outlined, "Category",
                        product["category"]),
                    _buildDetailRow(Icons.notes_outlined, "Description",
                        product["description"]),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: _goldButton(
                    icon: FontAwesomeIcons.whatsapp,
                    label: 'Enquire on WhatsApp',
                    onTap: () => _launchWhatsApp(product),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _gold, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDBB458), Color(0xFFB98827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: .24),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatWeight(dynamic value) {
    if (value == null) return '';
    final text = '$value';
    if (text.toLowerCase().contains('g')) return text;
    return '${text}g';
  }
}
