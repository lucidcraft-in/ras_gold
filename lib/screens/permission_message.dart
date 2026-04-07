import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class PermissionMessage extends StatelessWidget {
  static const routeName = '/permission-screen';
  const PermissionMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 5, left: 55, right: 55),
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    // color: ,
                    child: Image.asset(
                      'assets/images/denied.png',
                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              "your account has been suspended",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "for activate your account please contact",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Thrissur Golden Jewellers administrator",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 37.0,
                  width: 70.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: const Icon(
                      FontAwesomeIcons.whatsapp,
                      size: 24,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await launchUrl(Uri.parse(
                          "https://wa.me/+91 8891441921?text=Hello Sir, I can't access my application."));
                    },
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                  height: 37.0,
                  width: 70.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: const FaIcon(
                      FontAwesomeIcons.phone,
                      color: Colors.white,
                      size: 17,
                    ),
                    onPressed: () async {
                      await launchUrl(Uri.parse("tel://4952419921"));
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
