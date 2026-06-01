// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../providers/category.dart';
import '../screens/product_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  final Category categoryDb = Category();
  var categoryList = [];

  Future<void> loadCategoary() async {
    categoryDb.initiliase();
    categoryDb.getCategorywithImg().then((value) {
      if (!mounted) return;
      setState(() {
        categoryList = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategoary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: _buildAppBar(),
      body: categoryList.isNotEmpty
          ? ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: categoryList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categoryList[index];
                return _categoryTile(category);
              },
            )
          : _emptyState(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F5F1),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: _ink),
      title: const Text(
        'Categories',
        style: TextStyle(
          color: _ink,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _categoryTile(dynamic category) {
    final String name = '${category["name"] ?? "Category"}';
    final String? image = category["image"];

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(category: name),
          ),
        );
      },
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .045),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      )
                    : _fallbackIcon(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Explore gold collections',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right_rounded, color: _gold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Image(
        height: 34,
        width: 34,
        color: _deepGold,
        image: AssetImage("assets/images/icons8-jewelry-64.png"),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
        ),
        child: const Text(
          "No Category Found",
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
