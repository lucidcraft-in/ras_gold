import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/transaction_list.dart';
import '../providers/transaction.dart';
import '../providers/user.dart';
import 'homeNavigation.dart';
import 'profile.dart';

class TransactionScreen extends StatefulWidget {
  static const routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  var user;
  bool? _checkValue;
  Transaction? db;
  User? dbUser;
  List transactionList = [];
  List userList = [];
  DateTime lastUpdate = DateTime.now();
  double customerBalance = 0;
  double totalGram = 0;
  List alllist = [];

  initialise() {
    db = Transaction();
    dbUser = User();
    db!.initiliase();

    db!.read(user['id']).then((value) {
      setState(() {
        alllist = value!;
        transactionList = alllist[0];
      });

      // print("------------ user -------------");
      // print(transactionList);
    });
  }

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _checkValue = prefs.containsKey('user');
    // print(_checkValue);
    if (_checkValue == true) {
      setState(() {
        user = jsonDecode(prefs.getString('user')!);
      });
      // print("==========");
      // print(user["schemeType"]);
      await initialise();
    }

    // user = prefs.containsKey('user');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
    checkUser();
  }

  bool checkValue = false;
  checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    checkValue = prefs.containsKey('user');
    // if (_checkValue == true) {
    //   Navigator.of(context).pushNamed(TransactionScreen.routeName);
    // } else {
    //   Navigator.of(context).pushNamed(LoginScreen.routeName);
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (transactionList.isNotEmpty) {
      lastUpdate = transactionList[0]['date'].toDate();
    }

    // if (userList != null) {
    //   customerBalance = userList[0]['balance'].toDouble();
    //   totalGram = userList[0]["totalGram"].toDouble();
    // }

    // Clear shared preferance
    logout() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.getKeys();
      for (String key in preferences.getKeys()) {
        preferences.remove(key);
      }

      setState(() {});
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeNavigation()),
          (Route route) => false);
      // Navigator.pushReplacement(context,
      //     new MaterialPageRoute(builder: (context) => new HomeNavigation()));

      // Navigate Page
      // Navigator.of(context).pushNamed(HomeScreen.routeName);
    }

    return checkValue == true
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 2,
              // centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text(
                "Transaction",
              ),
            ),
            body: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                // padding: EdgeInsets.only(top: 35),
                color: Colors.white,
                child: const Column(
                  children: [
                    // titleCard(),

                    Expanded(child: TransactionList()),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 2,
              backgroundColor: Theme.of(context).primaryColor,
              centerTitle: true,
              title: const Text(
                "TRANSACTIONS",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'latto',
                    fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height * .7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                      image:
                          AssetImage("assets/images/Mobile login-amico.png")),
                  const Text("Your Not Log in",
                      style: TextStyle(
                          fontSize: 18, color: Color.fromARGB(255, 0, 0, 0))),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Goto SignIn",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 0, 0, 0))),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );

    // Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text('Welcome! Please log in.'),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(builder: (context) => LoginScreen()),
    //             );
    //           },
    //           child: Text('Go to Login Page'),
    //         ),
    //       ],
    //     ),
    //   );
  }

  Widget titleCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .22,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/bg2.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15.0), // Border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: const Offset(3, 3), // Offset of the shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Image(
                  color: Color.fromARGB(255, 205, 168, 65),
                  width: 40,
                  image: AssetImage("assets/images/gold-ingot.png")),
              const SizedBox(height: 10),
              user["schemeType"] == "Gold"
                  ? Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "Gold In locker",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Center(
                              child: Text(
                                "${totalGram.toStringAsFixed(4)} gms",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          "Cash As Saving",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.indianRupeeSign,
                            size: 20,
                          ),
                          Text(
                            customerBalance.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Last updated at",
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'latto',
                        color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat.yMMMd()
                        // .add_jm()
                        .format(lastUpdate)
                        .toString(),
                    style: const TextStyle(
                        fontFamily: 'latto', fontSize: 11, color: Colors.grey),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
