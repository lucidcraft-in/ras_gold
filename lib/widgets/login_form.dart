import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/getDeviceId.dart';
import '../screens/newHomeScreen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  // static const routeName = "/login-screen-form";
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _form = GlobalKey<FormState>();

  Future<bool> login() async {
    String custId = _customerIdController.text.trim();
    String password = _passwordController.text.trim();

    if (custId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter credentials")),
      );
      return false;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('custId', isEqualTo: custId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer id is invalid!")),
        );
        return false;
      }

      if (!mounted) return false;

      var userDoc = snapshot.docs.first;
      var userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = userDoc.id;

      if (userData['phone_no'] != password) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password!")),
        );
        return false;
      }

      String currentDeviceId = await getDeviceId();

      if (!mounted) return false;
      // String? token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return false;

      String? savedDeviceId = userData['deviceId'];

      if (savedDeviceId == null || savedDeviceId.isEmpty) {
        await userDoc.reference.set({
          'deviceId': currentDeviceId,
          'token': "",
        }, SetOptions(merge: true));

        if (!mounted) return false;
      } else if (savedDeviceId != currentDeviceId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account already logged in on another device")),
        );
        return false;
      }

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      if (!mounted) return false;

      sharedPreferences.setString(
          "user",
          json.encode(userData, toEncodable: (item) {
            if (item is Timestamp) {
              return item.toDate().toIso8601String();
            }
            return item;
          }));

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          _field(
            controller: _customerIdController,
            label: "Customer Id",
            icon: Icons.badge_outlined,
            validatorText: 'Please provide valid customer id.',
          ),
          const SizedBox(height: 14),
          _field(
            controller: _passwordController,
            label: "Password",
            icon: Icons.lock_outline_rounded,
            validatorText: 'Please provide a value.',
          ),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (_form.currentState?.validate() ?? false) {
                login();
              }
            },
            child: Container(
              height: 54,
              width: double.infinity,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorText,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.left,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        return null;
      },
      obscureText: false,
      style: const TextStyle(
        color: _ink,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted, fontSize: 13),
        prefixIcon: Icon(icon, color: _gold, size: 21),
        filled: true,
        fillColor: const Color(0xFFFFFCF7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _deepGold, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
