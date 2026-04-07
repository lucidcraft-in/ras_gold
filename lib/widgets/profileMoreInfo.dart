import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMoreInfo extends StatelessWidget {
  const ProfileMoreInfo({super.key, required this.label, required this.icon});
  final String label;
  final icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .05,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
              ),
            ),
            const SizedBox(width: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textStyle: const TextStyle(
                      color: Color.fromARGB(255, 140, 140, 140),
                      letterSpacing: .5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
