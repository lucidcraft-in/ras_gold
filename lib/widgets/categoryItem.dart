import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  const CategoryItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/necklace.png')),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
