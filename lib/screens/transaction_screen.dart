// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import '../widgets/transaction_list.dart';
// import '../providers/transaction.dart';
// import '../providers/user.dart';
// import 'homeNavigation.dart';
// import 'profile.dart';

// class TransactionScreen extends StatefulWidget {
//   static const routeName = "/transaction-screen";

//   const TransactionScreen({super.key});

//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }

// class _TransactionScreenState extends State<TransactionScreen> {
//   var user;
//   bool? _checkValue;
//   Transaction? db;
//   User? dbUser;
//   List transactionList = [];
//   List userList = [];
//   DateTime lastUpdate = DateTime.now();
//   double customerBalance = 0;
//   double totalGram = 0;
//   List alllist = [];

//   initialise() {
//     db = Transaction();
//     dbUser = User();
//     db!.initiliase();

//     db!.read(user['id']).then((value) {
//       setState(() {
//         alllist = value!;
//         transactionList = alllist[0];
//       });

//       // print("------------ user -------------");
//       // print(transactionList);
//     });
//   }

//   checkLogin() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _checkValue = prefs.containsKey('user');
//     // print(_checkValue);
//     if (_checkValue == true) {
//       setState(() {
//         user = jsonDecode(prefs.getString('user')!);
//       });
//       // print("==========");
//       // print(user["schemeType"]);
//       await initialise();
//     }

//     // user = prefs.containsKey('user');
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     checkLogin();
//     checkUser();
//   }

//   bool checkValue = false;
//   checkUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     checkValue = prefs.containsKey('user');
//     // if (_checkValue == true) {
//     //   Navigator.of(context).pushNamed(TransactionScreen.routeName);
//     // } else {
//     //   Navigator.of(context).pushNamed(LoginScreen.routeName);
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (transactionList.isNotEmpty) {
//       lastUpdate = transactionList[0]['date'].toDate();
//     }

//     // if (userList != null) {
//     //   customerBalance = userList[0]['balance'].toDouble();
//     //   totalGram = userList[0]["totalGram"].toDouble();
//     // }

//     // Clear shared preferance
//     logout() async {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       preferences.getKeys();
//       for (String key in preferences.getKeys()) {
//         preferences.remove(key);
//       }

//       setState(() {});
//       Navigator.pop(context);
//       Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const HomeNavigation()),
//           (Route route) => false);
//       // Navigator.pushReplacement(context,
//       //     new MaterialPageRoute(builder: (context) => new HomeNavigation()));

//       // Navigate Page
//       // Navigator.of(context).pushNamed(HomeScreen.routeName);
//     }

//     return checkValue == true
//         ? Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               elevation: 2,
//               // centerTitle: true,
//               iconTheme: const IconThemeData(color: Colors.black),
//               backgroundColor: Theme.of(context).primaryColor,
//               title: const Text(
//                 "Transaction",
//               ),
//             ),
//             body: SafeArea(
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 // padding: EdgeInsets.only(top: 35),
//                 color: Colors.white,
//                 child: const Column(
//                   children: [
//                     // titleCard(),

//                     Expanded(child: TransactionList()),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : Scaffold(
//             appBar: AppBar(
//               elevation: 2,
//               backgroundColor: Theme.of(context).primaryColor,
//               centerTitle: true,
//               title: const Text(
//                 "TRANSACTIONS",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontFamily: 'latto',
//                     fontWeight: FontWeight.bold),
//               ),
//               iconTheme: const IconThemeData(color: Colors.white),
//             ),
//             body: SizedBox(
//               height: MediaQuery.of(context).size.height * .7,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Image(
//                       image:
//                           AssetImage("assets/images/Mobile login-amico.png")),
//                   const Text("Your Not Log in",
//                       style: TextStyle(
//                           fontSize: 18, color: Color.fromARGB(255, 0, 0, 0))),
//                   const SizedBox(height: 18),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const ProfileScreen()));
//                     },
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Goto SignIn",
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color.fromARGB(255, 0, 0, 0))),
//                         Icon(
//                           Icons.arrow_forward,
//                           size: 18,
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );

//     // Center(
//     //     child: Column(
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: [
//     //         Text('Welcome! Please log in.'),
//     //         SizedBox(height: 20),
//     //         ElevatedButton(
//     //           onPressed: () {
//     //             Navigator.push(
//     //               context,
//     //               MaterialPageRoute(builder: (context) => LoginScreen()),
//     //             );
//     //           },
//     //           child: Text('Go to Login Page'),
//     //         ),
//     //       ],
//     //     ),
//     //   );
//   }

//   Widget titleCard() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height * .22,
//         decoration: BoxDecoration(
//           image: const DecorationImage(
//             image: AssetImage("assets/images/bg2.png"),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.circular(15.0), // Border radius
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1), // Shadow color
//               spreadRadius: 2, // Spread radius
//               blurRadius: 5, // Blur radius
//               offset: const Offset(3, 3), // Offset of the shadow
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               const Image(
//                   color: Color.fromARGB(255, 205, 168, 65),
//                   width: 40,
//                   image: AssetImage("assets/images/gold-ingot.png")),
//               const SizedBox(height: 10),
//               user["schemeType"] == "Gold"
//                   ? Expanded(
//                       child: Container(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Center(
//                               child: Text(
//                                 "Gold In locker",
//                                 style: TextStyle(
//                                     fontSize: 11, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Center(
//                               child: Text(
//                                 "${totalGram.toStringAsFixed(4)} gms",
//                                 style: const TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   : Container(),
//               Expanded(
//                 child: Container(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const Center(
//                         child: Text(
//                           "Cash As Saving",
//                           style: TextStyle(
//                               fontSize: 11, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             FontAwesomeIcons.indianRupeeSign,
//                             size: 20,
//                           ),
//                           Text(
//                             customerBalance.toStringAsFixed(2),
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Last updated at",
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontFamily: 'latto',
//                         color: Colors.grey[400]),
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     DateFormat.yMMMd()
//                         // .add_jm()
//                         .format(lastUpdate)
//                         .toString(),
//                     style: const TextStyle(
//                         fontFamily: 'latto', fontSize: 11, color: Colors.grey),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:raz_gold/screens/contactUs.dart';
import 'package:raz_gold/screens/newHomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/transaction.dart';
import '../providers/user.dart';
import '../widgets/transaction_list.dart';
import 'homeNavigation.dart';
import 'profile.dart';

class TransactionScreen extends StatefulWidget {
  static const routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  var user;

  bool? _checkValue;
  bool checkValue = false;

  Transaction? db;
  User? dbUser;

  List transactionList = [];
  List userList = [];
  List alllist = [];

  @override
  void initState() {
    super.initState();
    checkLogin();
    checkUser();
  }

  Future<void> initialise() async {
    db = Transaction();
    dbUser = User();

    db!.initiliase();

    db!.read(user['id']).then((value) {
      if (!mounted) return;

      setState(() {
        alllist = value ?? [];
        if (alllist.isNotEmpty) {
          transactionList = alllist[0];
        }
      });
    });
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _checkValue = prefs.containsKey('user');

    if (_checkValue == true) {
      setState(() {
        user = jsonDecode(prefs.getString('user')!);
      });

      await initialise();
    }
  }

  Future<void> checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      checkValue = prefs.containsKey('user');
    });
  }

  Future<void> logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    for (String key in preferences.getKeys()) {
      preferences.remove(key);
    }

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (Route route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return checkValue
        ? Scaffold(
            backgroundColor: const Color(0xFFF7F5F1),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF7F5F1),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: _ink,
              ),
              title: const Text(
                "Transactions",
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: _ink,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        await logout();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 10),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            body: SafeArea(
              child: TransactionList(),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFF7F5F1),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF7F5F1),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: _ink,
              ),
              title: const Text(
                "Transactions",
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _line,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Image(
                      height: 180,
                      image: AssetImage(
                        "assets/images/Mobile login-amico.png",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Please Sign In",
                      style: TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Login to view your transactions,\ninvestment history and balance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
