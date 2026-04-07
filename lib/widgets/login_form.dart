import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/user.dart';
import '../functions/getDeviceId.dart';
import '../screens/newHomeScreen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  // static const routeName = "/login-screen-form";
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  User? db;

  // List userList = [];
  // List filterList = [];

  var index;

  // initialise() {
  //   db = User();
  //   db?.initiliase();
  //   db?.read().then((value) {
  //     setState(() {
  //       userList = value!;
  //     });
  //     print(userList);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // initialise();
  }

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _form = GlobalKey<FormState>();
  TextStyle style = const TextStyle(
    fontFamily: 'latto',
    fontSize: 20.0,
    color: Colors.white,
  );

  Future<bool> login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String custId = _customerIdController.text.trim();
    String password = _passwordController.text.trim();

    if (custId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter credentials")),
      );
      return false;
    }

    try {
      // 🔹 Query only this user
      print("custId: $custId, password: $password");
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
      // ✅ Manually inject the document ID so it's globally available
      userData['id'] = userDoc.id;

      // 🔐 Password check
      if (userData['phone_no'] != password) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password!")),
        );
        return false;
      }

      // 🔹 Device ID
      String currentDeviceId = await getDeviceId();

      if (!mounted) return false;
      // String? token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return false;

      String? savedDeviceId = userData['deviceId'];

      // ✅ First time login
      if (savedDeviceId == null || savedDeviceId.isEmpty) {
        await userDoc.reference.set({
          'deviceId': currentDeviceId,
          'token': "",
        }, SetOptions(merge: true));

        if (!mounted) return false;
      }
      // ❌ Already logged in another device
      else if (savedDeviceId != currentDeviceId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account already logged in on another device")),
        );
        return false;
      }

      // ✅ Save session locally
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _form,
        child: Container(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(children: <Widget>[
            TextFormField(
              controller: _customerIdController,
              textAlign: TextAlign.left,
              // controller: _emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please provide Valid customer id.';
                }
                return null;
              },
              obscureText: false,
              style: const TextStyle(
                  color: Color.fromARGB(255, 73, 73, 73), fontSize: 18),
              decoration: InputDecoration(
                hintText: "Customer Id",
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 52, 52, 52)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _passwordController,
              textAlign: TextAlign.left,
              // controller: _emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please provide a value.';
                }
                return null;
              },
              obscureText: false,
              style: const TextStyle(
                  color: Color.fromARGB(255, 47, 47, 47), fontSize: 18),
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 52, 52, 52)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Material(
  elevation: 1.0,
  borderRadius: BorderRadius.circular(12.0),
  color: const Color(0xFF460218), // 🔥 button bg color
  child: MaterialButton(
    minWidth: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    onPressed: () {
      login();
    },
    child: ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Color(0xFFedc860),
          Color(0xFFd89f32),
          Color(0xFFe1b753),
        ],
      ).createShader(bounds),
      child: Text(
        "Login",
        textAlign: TextAlign.center,
        style: style.copyWith(
          color: Colors.white, // must
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

            ),
          ]),
        ),
      ),
    );
  }
}
