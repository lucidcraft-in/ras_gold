import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login-screen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
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
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/app icon1.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
