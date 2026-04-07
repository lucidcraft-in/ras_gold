// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:oro_user/screens/uploadPaymentImage/onlinePaymentScreen.dart';
// import 'package:printing/printing.dart';
// import 'package:provider/provider.dart';
// import 'package:quickalert/quickalert.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../providers/banner.dart';
// import '../../providers/goldrate.dart';
// import 'sendPaymentRecipt.dart';

// class PaymentOptionsPage extends StatefulWidget {
//   const PaymentOptionsPage({Key? key}) : super(key: key);

//   @override
//   State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
// }

// class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
//   bool _checkValue = false;
//   var user;
//   checkLogin() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _checkValue = prefs.containsKey('user');
//     // print(_checkValue);
//     if (_checkValue) {
//       QuickAlert.show(
//           title: "Select Option",
//           cancelBtnText: "Online Payment",
//           cancelBtnTextStyle: TextStyle(
//               fontSize: 10,
//               color: Theme.of(context).primaryColor,
//               fontWeight: FontWeight.bold),
//           onCancelBtnTap: () {
//             Navigator.pop(context);
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => Onlinepaymentscreen()));

//             // QuickAlert.show(
//             //     context: context,
//             //     type: QuickAlertType.error,
//             //     title: 'Oops...',
//             //     text: 'Sorry,currently Online Payment Not available',
//             //     confirmBtnColor: Theme.of(context).primaryColor,
//             //     confirmBtnTextStyle: TextStyle(
//             //         fontSize: 13,
//             //         color: Colors.white,
//             //         fontWeight: FontWeight.bold),
//             //     onConfirmBtnTap: () {
//             //       Navigator.pop(context);
//             //     });
//           },
//           onConfirmBtnTap: () {
//             Navigator.pop(context);
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => SendPaymentRec()));
//           },
//           confirmBtnColor: Theme.of(context).primaryColor,
//           confirmBtnTextStyle: TextStyle(
//               fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
//           context: context,
//           type: QuickAlertType.info,
//           showCancelBtn: true,
//           text: 'Complete your payment Online or Share screenshot',
//           // cancelBtnText: "Share Screenshot",
//           confirmBtnText: "Share Screenshot"

//           // Online Payment",
//           );

//       // Navigator.push(
//       //     context,
//       //     MaterialPageRoute(
//       //         builder: (context) => MakePayment()));
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Your not login '),
//             content: Text('Upload Payment Details after Login...!'),
//             actions: [
//               ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                         Theme.of(context).primaryColor),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('OK')),
//             ],
//           );
//         },
//       );
//     }
//   }

//   Goldrate? db;
//   List goldrateList = [];
//   double pavanrate = 0;
//   String golddate = "";
//   String goldTime = "";
//   initialise() {
//     db = Goldrate();
//     db?.initiliase();
//     db?.read().then((value) => {
//           setState(() {
//             goldrateList = value!;
//             pavanrate = goldrateList[0]["pavan"];
//             goldTime = goldrateList[0]["updateTime"];
//             golddate = goldrateList[0]["updateDate"];
//           }),
//         });
//     // getProduct();
//   }

//   List imgList = [];
//   getSlider() {
//     Provider.of<BannerProvider>(context, listen: false)
//         .getSlide("Banner")
//         .then((value) {
//       setState(() {
//         imgList = value;
//       });
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initialise();
//     getSlider();
//     checkLogin();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Select Option"),
//           backgroundColor: Theme.of(context).primaryColor,
//         ),
//         body: Container(
//           color: Colors.white,
//           height: MediaQuery.of(context).size.height,
//           width: double.infinity,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height * .11,
//                   child: Stack(
//                     children: [
//                       // Parent Container with a background image
//                       Positioned.fill(
//                         // Ensures the child covers the entire Stack
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             color: Color(0xFFF5F1F1),
//                             image: DecorationImage(
//                               image: AssetImage(
//                                   "assets/icons/statrs.png"), // Your image path
//                               fit: BoxFit.contain, // Adjust image to container
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Content container
//                       Positioned(
//                         // Make sure it also fills the parent Stack
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * .11,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             color: Colors
//                                 .transparent, // Transparent to show the background image
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Gold Rate | 22K"),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       pavanrate.toStringAsFixed(2),
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 17,
//                                         color: Color.fromARGB(255, 152, 38, 30),
//                                       ),
//                                     ),
//                                     Text(" (8 gram)"),
//                                   ],
//                                 ),
//                                 // Text(
//                                 //   "Updated at ${goldTime} on ${golddate}",
//                                 //   style: TextStyle(
//                                 //     fontSize: 12,
//                                 //     fontWeight: FontWeight.w500,
//                                 //     color: Color.fromARGB(255, 142, 139, 139),
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(150),
//                   ),
//                   child: Stack(
//                     children: [
//                       // Parent Container with a background image
//                       Container(
//                         width: double.infinity,
//                         height: 210, // Adjust the height as per your needs
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           image: DecorationImage(
//                             image: imgList.length > 0
//                                 ? NetworkImage(imgList[0]["photo"])
//                                 : AssetImage(
//                                     'assets/images/bannerImg.jpeg'), // Replace with your image path
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                       // Overlay Container with gradient
//                       Container(
//                         width: double.infinity,
//                         height:
//                             200, // Adjust to match the parent container's height
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           gradient: LinearGradient(
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                             colors: [
//                               Colors.black
//                                   .withOpacity(0.2), // Black at the bottom
//                               Colors.transparent, // Transparent at the top
//                             ],
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Container(
//                                 height: 70,
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           "Now you Can Pay Online",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 13,
//                                               color: Color.fromARGB(
//                                                   255, 255, 255, 255)),
//                                         ),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           // if (_checkValue) {
//                                           //   Navigator.push(
//                                           //       context,
//                                           //       MaterialPageRoute(
//                                           //           builder: (context) =>
//                                           //               SendPaymentRec()));
//                                           // } else {
//                                           //   showDialog(
//                                           //     context: context,
//                                           //     builder: (BuildContext context) {
//                                           //       return AlertDialog(
//                                           //         title: Text('Your not login '),
//                                           //         content: Text(
//                                           //             'Upload Payment Details after Login...!'),
//                                           //         actions: [
//                                           //           ElevatedButton(
//                                           //               style: ButtonStyle(
//                                           //                 backgroundColor:
//                                           //                     MaterialStateProperty.all<
//                                           //                         Color>(Theme.of(
//                                           //                             context)
//                                           //                         .primaryColor),
//                                           //               ),
//                                           //               onPressed: () {
//                                           //                 Navigator.of(context)
//                                           //                     .pop();
//                                           //               },
//                                           //               child: Text('OK')),
//                                           //         ],
//                                           //       );
//                                           //     },
//                                           //   );
//                                           // }
//                                           // if (_checkValue) {
//                                           //   QuickAlert.show(
//                                           //     title: "Select Option",
//                                           //     cancelBtnTextStyle: TextStyle(
//                                           //         fontSize: 10,
//                                           //         color: Theme.of(context)
//                                           //             .primaryColor,
//                                           //         fontWeight: FontWeight.bold),
//                                           //     onCancelBtnTap: () {
//                                           //       Navigator.pop(context);
//                                           //       Navigator.push(
//                                           //           context,
//                                           //           MaterialPageRoute(
//                                           //               builder: (context) =>
//                                           //                   SendPaymentRec()));
//                                           //     },
//                                           //     onConfirmBtnTap: () {
//                                           //       Navigator.pop(context);
//                                           //       // Navigator.push(
//                                           //       //     context,
//                                           //       //     MaterialPageRoute(
//                                           //       //         builder: (context) =>
//                                           //       //             MakePayment()));
//                                           //       // _launchGooglePay();
//                                           //       QuickAlert.show(
//                                           //           context: context,
//                                           //           type: QuickAlertType.error,
//                                           //           title: 'Oops...',
//                                           //           text:
//                                           //               'Sorry,currently Online Payment Not available',
//                                           //           confirmBtnColor:
//                                           //               Theme.of(context)
//                                           //                   .primaryColor,
//                                           //           confirmBtnTextStyle:
//                                           //               TextStyle(
//                                           //                   fontSize: 13,
//                                           //                   color: Colors.white,
//                                           //                   fontWeight:
//                                           //                       FontWeight
//                                           //                           .bold),
//                                           //           onConfirmBtnTap: () {
//                                           //             Navigator.pop(context);
//                                           //           });
//                                           //     },
//                                           //     confirmBtnColor: Theme.of(context)
//                                           //         .primaryColor,
//                                           //     confirmBtnTextStyle: TextStyle(
//                                           //         fontSize: 10,
//                                           //         color: Colors.white,
//                                           //         fontWeight: FontWeight.bold),
//                                           //     context: context,
//                                           //     type: QuickAlertType.info,
//                                           //     showCancelBtn: true,
//                                           //     text:
//                                           //         'Complete your payment Online or Share screenshot',
//                                           //     cancelBtnText: "Share Screenshot",
//                                           //     confirmBtnText: "Online Payment",
//                                           //   );

//                                           //   // Navigator.push(
//                                           //   //     context,
//                                           //   //     MaterialPageRoute(
//                                           //   //         builder: (context) => MakePayment()));
//                                           // } else {
//                                           //   showDialog(
//                                           //     context: context,
//                                           //     builder: (BuildContext context) {
//                                           //       return AlertDialog(
//                                           //         title:
//                                           //             Text('Your not login '),
//                                           //         content: Text(
//                                           //             'Upload Payment Details after Login...!'),
//                                           //         actions: [
//                                           //           ElevatedButton(
//                                           //               style: ButtonStyle(
//                                           //                 backgroundColor:
//                                           //                     MaterialStateProperty.all<
//                                           //                         Color>(Theme.of(
//                                           //                             context)
//                                           //                         .primaryColor),
//                                           //               ),
//                                           //               onPressed: () {
//                                           //                 Navigator.of(context)
//                                           //                     .pop();
//                                           //               },
//                                           //               child: Text('OK')),
//                                           //         ],
//                                           //       );
//                                           //     },
//                                           //   );
//                                           // }
//                                           if (_checkValue) {
//                                             QuickAlert.show(
//                                                 title: "Select Option",
//                                                 cancelBtnTextStyle: TextStyle(
//                                                     fontSize: 10,
//                                                     color: Theme.of(context)
//                                                         .primaryColor,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                                 // onCancelBtnTap: () {
//                                                 //   Navigator.pop(context);
//                                                 //   // Navigator.push(
//                                                 //   //     context,
//                                                 //   //     MaterialPageRoute(
//                                                 //   //         builder: (context) =>
//                                                 //   //             MakePayment()));
//                                                 //   // _launchGooglePay();
//                                                 //   QuickAlert.show(
//                                                 //       context: context,
//                                                 //       type: QuickAlertType.error,
//                                                 //       title: 'Oops...',
//                                                 //       text: 'Sorry,currently Online Payment Not available',
//                                                 //       confirmBtnColor: Theme.of(context).primaryColor,
//                                                 //       confirmBtnTextStyle: TextStyle(
//                                                 //           fontSize: 13,
//                                                 //           color: Colors.white,
//                                                 //           fontWeight: FontWeight.bold),
//                                                 //       onConfirmBtnTap: () {
//                                                 //         Navigator.pop(context);
//                                                 //       });
//                                                 // },
//                                                 onConfirmBtnTap: () {
//                                                   Navigator.pop(context);
//                                                   Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               SendPaymentRec()));
//                                                 },
//                                                 confirmBtnColor:
//                                                     Theme.of(context)
//                                                         .primaryColor,
//                                                 confirmBtnTextStyle: TextStyle(
//                                                     fontSize: 10,
//                                                     color: Colors.white,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                                 context: context,
//                                                 type: QuickAlertType.info,
//                                                 showCancelBtn: true,
//                                                 text:
//                                                     'Complete your payment Online or Share screenshot',
//                                                 // cancelBtnText: "Share Screenshot",
//                                                 confirmBtnText:
//                                                     "Share Screenshot"

//                                                 // Online Payment",
//                                                 );

//                                             // Navigator.push(
//                                             //     context,
//                                             //     MaterialPageRoute(
//                                             //         builder: (context) => MakePayment()));
//                                           } else {
//                                             showDialog(
//                                               context: context,
//                                               builder: (BuildContext context) {
//                                                 return AlertDialog(
//                                                   title:
//                                                       Text('Your not login '),
//                                                   content: Text(
//                                                       'Upload Payment Details after Login...!'),
//                                                   actions: [
//                                                     ElevatedButton(
//                                                         style: ButtonStyle(
//                                                           backgroundColor:
//                                                               MaterialStateProperty.all<
//                                                                   Color>(Theme.of(
//                                                                       context)
//                                                                   .primaryColor),
//                                                         ),
//                                                         onPressed: () {
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                         },
//                                                         child: Text('OK')),
//                                                   ],
//                                                 );
//                                               },
//                                             );
//                                           }
//                                         },
//                                         child: Container(
//                                           height: 30,
//                                           width: 100,
//                                           decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(12)),
//                                           child: Center(
//                                             child: Text(
//                                               "Pay Now",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 15,
//                                                   color: Color.fromARGB(
//                                                       255, 53, 10, 10)),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }
