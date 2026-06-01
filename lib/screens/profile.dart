import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_pinput/new_pinput.dart';
import 'package:raz_gold/screens/login_screen.dart';
import 'package:raz_gold/screens/newHomeScreen.dart';
import 'package:raz_gold/screens/pdfload.dart/aboutUs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/login_form.dart';
import '../widgets/profileMoreInfo.dart';
import '../widgets/profile_name_tag.dart';
import 'contactUs.dart';
import 'pdfload.dart/privacypolicy.dart';
import 'pdfload.dart/refundPolicy.dart';
import 'pdfload.dart/terms.dart';
import 'uploadPaymentImage/getAllSubmitRec.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? filePath;
  String? fileName;
  bool checkValue = false;
  final bool _isLoad = false;
  var user;
  checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkValue = prefs.containsKey('user');

    if (checkValue == true) {
      setState(() {
        var data = prefs.getString("user");
        setState(() {
          user = jsonDecode(data!);
        });
      });
    }
  }

  void pickFile() async {
    // 1.pick image
// 2.upload firestore
// 3.update field

// 1.pick image
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        filePath = result.files.single.path!;
        fileName = result.files.single.name;
      });

// 2.upload firestore
      try {
        final firbase_storage.FirebaseStorage storage =
            firbase_storage.FirebaseStorage.instance;
        firbase_storage.TaskSnapshot taskSnapshot =
            await storage.ref('profilePic/$fileName').putFile(File(filePath!));
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        FirebaseFirestore.instance
            .collection('user')
            .doc(user['id'])
            .update({'profileImage': downloadUrl});
      } catch (e) {}
    } else {}
  }

  Future<bool> _loadProfileData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate a network call
    return true; // Simulate data load success
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return checkValue == false
        ? Scaffold(
            appBar: AppBar(
              elevation: 2,
              backgroundColor: const Color(0xFF460218),
              centerTitle: true,

              // 🔥 Icon gradient
              iconTheme: const IconThemeData(color: Colors.white), // base color

              title: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white, // must
                    fontSize: 14,
                    fontFamily: 'latto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🔥 Back icon gradient
              leading: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height * .8,
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color.fromARGB(255, 241, 230, 230),
                    backgroundImage: AssetImage("assets/images/face1.png"),
                  ),
                  LoginForm(),
                  // Container(
                  //   width: double.infinity,
                  //   height: MediaQuery.of(context).size.height * .05,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(left: 30.0, right: 30),
                  //     child: ElevatedButton(
                  //         onPressed: _showMobileLoginSheet,
                  //         child: Text(
                  //           'Login with Mobile',
                  //           style: TextStyle(
                  //               color: Theme.of(context).primaryColor),
                  //         ),
                  //         style: ButtonStyle(
                  //             backgroundColor: MaterialStateProperty.all<Color>(
                  //               Color.fromARGB(255, 255, 255, 255),
                  //             ),
                  //             shape: MaterialStateProperty.all<
                  //                     RoundedRectangleBorder>(
                  //                 RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(12.0),
                  //                     side: BorderSide(
                  //                         color:
                  //                             Theme.of(context).primaryColor))))

                  //         // style: ElevatedButton.styleFrom(
                  //         //     backgroundColor: Theme.of(context).primaryColor,
                  //         //     textStyle: TextStyle(
                  //         //         fontSize: 14, fontWeight: FontWeight.bold)),
                  //         ),
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        : !isProfile
            ? pageLogin()
            : profileSec();
  }

  Widget pageLogin() {
    final sizeH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 230, 230),
      appBar: AppBar(
        backgroundColor: const Color(0xFF460218),
        elevation: 2,
        centerTitle: true,

        // base icon color (must be white for gradient)
        iconTheme: const IconThemeData(color: Colors.white),

        // 🔥 Title gradient
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color(0xFFedc860),
              Color(0xFFd89f32),
              Color(0xFFe1b753),
            ],
          ).createShader(bounds),
          child: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.white, // must
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // 🔥 Back icon gradient
        leading: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color(0xFFedc860),
              Color(0xFFd89f32),
              Color(0xFFe1b753),
            ],
          ).createShader(bounds),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: sizeH,
        child: Column(
          children: [
            Container(
              height: sizeH * .02,
            ),
            Container(
              height: sizeH * .25,
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Container(
                  width: double.infinity,
                  // height: MediaQuery.of(context).size.height * .1,
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/bg.jpeg"),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(user['id'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return IconButton(
                                      icon: const CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            Color.fromARGB(255, 248, 223, 244),
                                        child: CircularProgressIndicator(),
                                      ),
                                      onPressed: () {},
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {}
                                  var userData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return IconButton(
                                    icon: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: const Color.fromARGB(
                                          255, 248, 223, 244),
                                      backgroundImage:
                                          userData['profileImage'] != ""
                                              ? NetworkImage(
                                                  userData['profileImage'])
                                              : const AssetImage(
                                                  "assets/images/face1.png"),
                                    ),
                                    onPressed: () {
                                      if (user != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfileScreen()));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen()));
                                      }
                                    },
                                  );
                                }),
                            // IconB
                            // CircleAvatar(
                            //   radius: 60,
                            //   backgroundColor:
                            //       Color.fromARGB(255, 241, 230, 230),
                            //   backgroundImage:
                            //   //  user['profileImage'] != ""
                            //   //     ? NetworkImage(user['profileImage'])
                            //   //     : AssetImage("assets/images/face1.png"),

                            // //    filePath != null
                            // //       ? FileImage(File(filePath!))
                            // //       : AssetImage("assets/images/face1.png"),
                            // // ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  pickFile();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: sizeH * .01,
                        ),
                        Text(
                          "${user["name"]}".toUpperCase(),
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            textStyle: const TextStyle(
                                color: Colors.black, letterSpacing: .5),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              height: sizeH * .5,
              child: Column(
                children: [
                  ProfileNameTag(
                    size: sizeH * .07,
                    icon: FontAwesomeIcons.user,
                    label: "Customer ID",
                    name: user["custId"],
                  ),
                  Container(
                    height: sizeH * .02,
                  ),
                  ProfileNameTag(
                    size: sizeH * .07,
                    icon: Icons.call,
                    label: "Phone Number",
                    name: user["phoneNo"],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubmittedRec(
                                    userId: user["id"],
                                  )));
                    },
                    child: const ProfileMoreInfo(
                        label: "Payment ", icon: Icons.currency_exchange),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => Contact()));
                  //   },
                  //   child: ProfileMoreInfo(
                  //       label: "Contact Us", icon: Icons.contact_emergency),
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsAndCondition()),
                      );
                    },
                    child: const ProfileMoreInfo(
                        label: "Terms and Condition", icon: Icons.menu_book),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RefundPolicyPage()),
                        );
                      },
                      child: const ProfileMoreInfo(
                          label: "Refund Policy", icon: Icons.restore)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyPolicy()),
                        );
                      },
                      child: const ProfileMoreInfo(
                          label: "Privacy Policy", icon: Icons.book)),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => Privacypolicy()),
                  //       );
                  //     },
                  //     child: ProfileMoreInfo(
                  //         label: "Privacy Policy", icon: Icons.policy)),

                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsPage()),
                        );
                      },
                      child: const ProfileMoreInfo(
                          label: "About Us", icon: Icons.policy)),

                  const Divider(),
                  ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('! Log out '),
                          // content: Text('Log out of Angadi'),
                          actions: <Widget>[
                            OutlinedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            OutlinedButton(
                              child: const Text('Log Out'),
                              onPressed: () {
                                logout();
                              },
                            )
                          ],
                        ),
                      );
                    },
                    leading: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: const Icon(
                        FontAwesomeIcons.signOut,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      "Log Out",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        textStyle: const TextStyle(
                            color: Colors.black, letterSpacing: .5),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isProfile = false;
  // Widget profileSec() {
  //   final sizeH = MediaQuery.of(context).size.height;
  //   return Scaffold(
  //     backgroundColor: const Color.fromARGB(255, 241, 230, 230),
  //     appBar: AppBar(
  //       leading: IconButton(
  //         onPressed: () {
  //           setState(() {
  //             isProfile = false;
  //           });
  //         },
  //         icon: const Icon(
  //           Icons.arrow_back,
  //           color: Colors.white,
  //         ),
  //       ),
  //       elevation: 2,
  //       backgroundColor: Theme.of(context).primaryColor,
  //       centerTitle: true,
  //       title: const Text(
  //         "My Profile",
  //         style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 14,
  //             fontFamily: 'latto',
  //             fontWeight: FontWeight.bold),
  //       ),
  //       iconTheme: const IconThemeData(color: Colors.white),
  //     ),
  //     body: Container(
  //       child: Column(
  //         children: [
  //           Container(
  //             height: sizeH * .02,
  //           ),
  //           Container(
  //             height: sizeH * .2,
  //             width: double.infinity,
  //             color: const Color.fromARGB(255, 255, 255, 255),
  //             child: const Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 CircleAvatar(
  //                   radius: 60,
  //                   backgroundColor: Color.fromARGB(255, 241, 230, 230),
  //                   backgroundImage: AssetImage("assets/images/face1.png"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           ProfileNameTag(
  //             size: sizeH * .09,
  //             icon: FontAwesomeIcons.user,
  //             label: "Name",
  //             name: user[0]["name"],
  //           ),
  //           Container(
  //             height: .2,
  //             width: double.infinity,
  //             color: Colors.grey,
  //           ),
  //           // ProfileNameTag(
  //           //     size: sizeH * .09,
  //           //     icon: Icons.mail_rounded,
  //           //     label: "Email",
  //           //     name: user["mail"]),
  //           Container(
  //             height: .2,
  //             width: double.infinity,
  //             color: Colors.grey,
  //           ),
  //           ProfileNameTag(
  //             size: sizeH * .09,
  //             icon: Icons.call,
  //             label: "Phone Number",
  //             name: user[0]["phoneNo"],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget profileSec() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              isProfile = false;
            });
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(user['id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Profile Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  const Color.fromARGB(255, 244, 231, 214),
                              backgroundImage: userData['profileImage'] !=
                                          null &&
                                      userData['profileImage'] != ""
                                  ? NetworkImage(
                                      userData['profileImage'],
                                    )
                                  : const AssetImage("assets/images/face1.png")
                                      as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickFile,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${userData['name'] ?? ''}".toUpperCase(),
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Customer ID : ${userData['custId'] ?? '-'}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// User Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _profileTile(
                        icon: Icons.person_outline,
                        title: "Name",
                        value: userData['name'] ?? '',
                      ),
                      const Divider(height: 1),
                      _profileTile(
                        icon: Icons.phone_outlined,
                        title: "Phone Number",
                        value: userData['phoneNo'] ?? '',
                      ),
                      const Divider(height: 1),
                      _profileTile(
                        icon: Icons.badge_outlined,
                        title: "Customer ID",
                        value: userData['custId'] ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: logout,
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 244, 231, 214),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.getKeys();
    for (String key in preferences.getKeys()) {
      preferences.remove(key);
    }
    setState(() {});
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user['id'])
        .update({'deviceId': ""});
    Navigator.pop(context);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route route) => false);
    // Navigator.pushReplacement(context,
    //     new MaterialPageRoute(builder: (context) => new HomeNavigation()));

    // Navigate Page
    // Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  void _showMobileLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Mobile Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set border radius here
                      border: Border.all(
                          color: Colors.grey), // Optionally, set border color
                    ),
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: TextStyle(color: Colors.red),
                        border: InputBorder.none, // Remove default border
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0), // Adjust padding
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubmittedRec(
                                    userId: user["id"],
                                  )));
                    },
                    child: const ProfileMoreInfo(
                        label: "Payment ", icon: Icons.currency_exchange),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Contact()));
                    },
                    child: const ProfileMoreInfo(
                        label: "Contact Us", icon: Icons.contact_emergency),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsAndCondition()),
                      );
                    },
                    child: const ProfileMoreInfo(
                        label: "Terms and Condition", icon: Icons.menu_book),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RefundPolicyPage()),
                        );
                      },
                      child: const ProfileMoreInfo(
                          label: "Refund Policy", icon: Icons.restore)),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => Privacypolicy()),
                  //       );
                  //     },
                  //     child: ProfileMoreInfo(
                  //         label: "Privacy Policy", icon: Icons.policy)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  final _otpController = TextEditingController();
  final _mobileController = TextEditingController();
  final pinController = TextEditingController();
  void _sendOtp(String userId) {
    // Navigator.pop(context); // Close the mobile number bottom sheet

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          setState(() {
            _secondsRemaining--;
          });

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter OTP',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Text('$_secondsRemaining seconds left'),
                    const Text('OTP Valid 2 Minute'),
                    !_showResendButton
                        ? Pinput(
                            androidSmsAutofillMethod:
                                AndroidSmsAutofillMethod.none,
                            controller: pinController,
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 60, 21, 28),
                                ),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            onPressed: () {
                              // _verifyOtp();
                              setState(() {
                                _showResendButton = false;
                                _secondsRemaining = 60;
                                _startTimer();
                              });
                            },
                            child: const Text('Resend OTP'),
                          ),
                    // TextFormField(
                    //   controller: _otpController,
                    //   decoration: InputDecoration(
                    //     labelText: 'OTP',
                    //   ),
                    //   keyboardType: TextInputType.number,
                    // ),

                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 60, 21, 28),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      onPressed: () {
                        // if (pinController.text.length < 4) {
                        //   SnackBar(
                        //     content: Text('Mobile number not registered'),
                        //   );
                        // } else {
                        //   _verifyOtp(userId, double.parse(pinController.text));
                        // }
                        // _verifyOtp(userId, double.parse(pinController.text));
                      },
                      child: const Text('Verify OTP'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if the state is mounted before updating
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
            _showResendButton = true;
          }
        });
      }
    });
  }

  bool _showResendButton = false;
  late Timer _timer;
  int _secondsRemaining = 60;

  @override
  void dispose() {
    // Dispose of the timers
    if (_timer.isActive) {
      _timer.cancel();
    }
    // Dispose of the controllers
    _otpController.dispose();
    _mobileController.dispose();
    pinController.dispose();
    super.dispose();
  }

  // _verifyOtp(String userId, double otpInput) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   String? token = await FirebaseMessaging.instance.getToken();
  //   final otp = _otpController.text;
  //   var databaseOtp;
  //   List userList = [];
  //   // print(userId);
  //   // print(otpInput.toStringAsFixed(0));
  //   // print("--");
  //   Provider.of<User>(context, listen: false)
  //       .getUserOtpByUser(userId)
  //       .then((val) {
  //     setState(() {
  //       databaseOtp = val[0];
  //       // print(databaseOtp.toString());
  //       // print("----------");
  //       // print(val[1].toDate());
  //       // print(DateTime.now());
  //       Duration difference = DateTime.now().difference(val[1].toDate());
  //       print(difference);
  //       if (difference.inMinutes <= 2) {
  //         print('The time difference exceeds 2 minutes.');
  //         if (databaseOtp == otpInput) {
  //           Provider.of<User>(context, listen: false)
  //               .readById(userId)
  //               .then((value) {
  //             setState(() {
  //               userList = value!;
  //             });
  //             print(userList);

  //             sharedPreferences.setString("user", json.encode(userList[0]));

  //             Navigator.of(context).pushAndRemoveUntil(
  //                 // MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
  //                 MaterialPageRoute(
  //                     builder: (BuildContext context) => HomeScreen()),
  //                 (Route<dynamic> route) => false);
  //           });
  //           print("====");
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('OTP Verified'),
  //             ),
  //           );
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Log In Success...'),
  //             ),
  //           );
  //         } else {
  //           print("----");
  //           Navigator.pop(context);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('OTP Verification Failed'),
  //             ),
  //           );
  //         }
  //       } else {
  //         print('The time difference does not exceed 2 minutes.');
  //         Navigator.pop(context);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('OTP Verification Time exceeds 2 minutes'),
  //           ),
  //         );
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('OTP Verification Failed'),
  //           ),
  //         );
  //       }
  //     });
  //   });
  //   // Simulate OTP verification delay
  //   // Future.delayed(Duration(seconds: 2), () {
  //   //   // Display success or failure message
  //   //   if (otp == '2222') {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(
  //   //         content: Text('OTP Verified'),
  //   //       ),
  //   //     );
  //   //   } else {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(
  //   //         content: Text('OTP Verification Failed'),
  //   //       ),
  //   //     );
  //   //   }
  //   // });

  //   // Close the OTP bottom sheet
  //   // Navigator.pop(context);

  //   // Start a timer
  //   // _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
  //   //   setState(() {
  //   //     if (_secondsRemaining > 0) {
  //   //       _secondsRemaining--;
  //   //     } else {
  //   //       _timer.cancel(); // Cancel the timer when the countdown reaches zero
  //   //       _showResendButton = true; // Show the "Resend OTP" button
  //   //     }
  //   //   });
  //   // });

  //   // Show Snackbar indicating OTP verification
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   SnackBar(
  //   //     content: Text('Verifying OTP...'),
  //   //   ),
  //   // );`
  // }

  // sendOtpToMobile(BuildContext context, String mobileNumber, int randomNumber,
  //     String userId) async {
  //   print("====");

  //   String url =
  //       'https://sapteleservices.in/SMS_API/sendsms.php?username=prakashjewellery&password=prakashpba610506&mobile=${mobileNumber.toString()}&message=${randomNumber}%20is%20the%20OTP%20for%20completing%20your%20login.%20Never%20share%20this%20OTP%20with%20anyone-Prakash%20Jewellery&sendername=PRAKJW&routetype=1&tid=1607100000000312467';
  //   print(url);
  //   var response = await http.get(Uri.parse(url));
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     print("suc---");
  //     print(response.body);
  //     Provider.of<User>(context, listen: false)
  //         .assignOtp(randomNumber.toDouble(), userId)
  //         .then((value) {
  //       print("-- ------");
  //       print(value);
  //       if (value == true) {
  //         Navigator.pop(context); //
  //         // ScaffoldMessenger.of(context).showSnackBar(
  //         //   SnackBar(
  //         //     content: Text('Otp send....'),
  //         //   ),
  //         // );
  //         Future.delayed(Duration(seconds: 1), () {
  //           _sendOtp(userId);
  //         });
  //       }
  //     });
  //   } else {
  //     print("error---");
  //     print(response.body);
  //   }
  // }
}
