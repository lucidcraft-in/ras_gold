import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raz_gold/providers/goldrate.dart';
import 'package:raz_gold/screens/categoryScreen.dart';
import 'package:raz_gold/screens/makePayment.dart';
import 'package:raz_gold/screens/transaction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/banner.dart';
import '../providers/category.dart';
import '../providers/product.dart';
import 'pdfload.dart/aboutUs.dart';
import 'productView.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data for the UI
  Map<String, double> goldPrices = {'1g': 0.00, '8g': 0.00, '18K': 0.00};

  List categories = [
    // {'name': 'Rings', 'icon': Icons.circle},
    // {'name': 'Necklaces', 'icon': FontAwesomeIcons.gem},
    // {'name': 'Earrings', 'icon': FontAwesomeIcons.earListen},
    // {'name': 'Bracelets', 'icon': FontAwesomeIcons.handHoldingHeart},
    // {'name': 'Pendants', 'icon': FontAwesomeIcons.medal},
  ];

  final List<Map<String, dynamic>> quickLinks = [
    {
      'name': 'Pay Now',
      'icon': Icons.payment,
      'color': const Color(0xFFF06292),
    },
    // {
    //   'name': 'Wishlist',
    //   'icon': Icons.favorite_border,
    //   'color': Color(0xFF64B5F6)
    // },
    // {
    //   'name': 'Gold Rates',
    //   'icon': FontAwesomeIcons.chartLine,
    //   'color': Color(0xFFFFB74D)
    // },
    {
      'name': 'View Transaction',
      'icon': Icons.receipt,
      'color': const Color(0xFF81C784),
    },
  ];

  List stores = [];

  List products = [];

  List banner = [];
  getSlider() {
    Provider.of<BannerProvider>(context, listen: false).getSlide('Banner').then(
      (onvalue) {
        setState(() {
          banner = onvalue;
        });
      },
    );
    Provider.of<BannerProvider>(context, listen: false).fetchData().then((val) {
      setState(() {
        stores = val;
      });
    });
  }

  String _userName = "";
  getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey("user")) {
      String? userData = pref.getString("user");
      if (userData != null) {
        Map<String, dynamic> user = json.decode(userData);
        setState(() {
          _userName = user['name'] ?? '';
        });
      }
    } else {
      setState(() {
        _userName = '';
      });
    }
  }

  List goldrateList = [];
  getGoldrate() {
    Provider.of<Goldrate>(context, listen: false).read().then((value) {
      if (value != null) {
        setState(() {
          goldrateList = value;
          goldPrices = {
            '1g': goldrateList[0]["gram"],
            '8g': goldrateList[0]["pavan"],
            '18K': goldrateList[0]["18gram"],
          };
        });
      }
    });
  }

  void getCategory() {
    Provider.of<Category>(context, listen: false).getCategory().then((onValue) {
      setState(() {
        // final List<Map<String, dynamic>> cleanedList =
        //     onValue.map<Map<String, dynamic>>((item) {
        //   return Map<String, dynamic>.from(item);
        // }).toList();

        // categories = convertCategories(cleanedList);
        categories = onValue;
      });
    });
  }

  getProduct() {
    Provider.of<Product>(context, listen: false)
        .getProduct()
        .then((onValue) {
          setState(() {
            products = onValue ?? [];
          });
        })
        .catchError((error) {
          setState(() {
            products = []; // Fallback to empty list on error
          });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getSlider();
    getGoldrate();
    getCategory();
    getProduct();
    fetchData();
  }

  Map<String, dynamic> aboutUsData = {};
  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('aboutUs')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          aboutUsData = data;
        });
      } else {}
    } catch (e) {}
  }

  void _launchWhatsApp() async {
    String phone = "91${aboutUsData["phone"]}";
    // Compose a meaningful WhatsApp message with product details
    String message = '''
Hello, I am interested in joining your gold scheme.
Kindly share the details. Thank you!
''';

    // Encode message for URL
    String whatsappUrl =
        "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";

    try {
      final Uri url = Uri.parse(whatsappUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF460218),
        title: Text(
          'Ras Gold & Diamonds',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFFedc860),
                  Color(0xFFd89f32),
                  Color(0xFFe1b753),
                ],
              ).createShader(Rect.fromLTWH(0, 0, 200, 20)),
          ),
        ),
        actions: [
          IconButton(
            icon: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(0xFFedc860),
                  Color(0xFFd89f32),
                  Color(0xFFe1b753),
                ],
              ).createShader(bounds),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white, // important
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_userName != "")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Welcome Back, ${_userName.toUpperCase()}"),
                  ),
                // Section 1: Banner
                _buildBannerSection(),

                // Section 2: Gold Price Section
                _buildGoldPriceSection(goldPrices),

                // Section 3: User Balance
                // _buildUserBalanceSection(userBalance),

                // Section 4: Product Categories
                _buildCategoriesSection(categories),

                // Section 5: Quick Links
                _buildQuickLinksSection(quickLinks),

                // Section 6: Store Locations
                _buildStoreLocationsSection(stores),

                // Section 7: Product Listing
                _buildProductsSection(products),

                // Extra padding at the bottom for floating button
                const SizedBox(height: 70),
              ],
            ),
          ),

          // WhatsApp floating button
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF460218),
              onPressed: _launchWhatsApp,
              child: const FaIcon(FontAwesomeIcons.whatsapp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return banner.isNotEmpty
        ? SizedBox(
            height: 180,
            width: double.infinity, // Ensures full width
            child: CarouselSlider.builder(
              itemCount: banner.length,
              itemBuilder: (context, index, realIndex) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: NetworkImage(banner[index]['photo']),
                    fit: BoxFit.cover, // Ensures image covers the entire space
                  ),
                );
              },
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: false, // Set to false for true full-width
                viewportFraction:
                    1.0, // Full width (1.0 = 100% of screen width)
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
              ),
            ),
          )
        : Container();
  }

  // Widget _buildGoldPriceSection(Map<String, double> prices) {
  //   return Container(
  //     margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Today\'s Gold Rate',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: prices.entries.map((entry) {
  //             return Expanded(
  //               child: Container(
  //                 padding: EdgeInsets.all(12),
  //                 margin: EdgeInsets.symmetric(horizontal: 4),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFFF5F5F5),
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Color(0xFFE0E0E0)),
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       entry.key,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.black54,
  //                       ),
  //                     ),
  //                     SizedBox(height: 8),
  //                     Text(
  //                       '${entry.value.toStringAsFixed(2)}',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFF4CAF50),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGoldPriceSection(Map<String, double> prices) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF0), Color(0xFFFFF8E1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPriceCards(prices),
            const SizedBox(height: 16),
            _buildLastUpdated(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 251, 251, 251),
                Color.fromARGB(255, 255, 255, 255),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Image(
              image: AssetImage("assets/images/app_icon.png"),
              width: 40,
              fit: BoxFit.cover,
            ),
          ),
          // Icon(
          //   Icons.diamond_outlined,
          //   color: Colors.white,
          //   size: 24,
          // ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: const Text(
                  "Today's Gold Rate",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // must
                  ),
                ),
              ),

              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'Live market prices',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // must
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF460218),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white, // must
                  size: 14,
                ),
              ),

              const SizedBox(width: 4),

              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFFedc860),
                    Color(0xFFd89f32),
                    Color(0xFFe1b753),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white, // must
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCards(Map<String, double> prices) {
    return Row(
      children: prices.entries.map((entry) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildGoldTypeIcon(entry.key),
                const SizedBox(height: 8),
                Text(
                  _getGoldLabel(entry.key),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getGoldTypeLabel(entry.key),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                // const SizedBox(height: 4),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF4CAF50).withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: const Text(
                //     '+0.5%',
                //     style: TextStyle(
                //       fontSize: 11,
                //       color: Color(0xFF4CAF50),
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoldTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case '1g':
        icon = Icons.grain;
        color = const Color(0xFFFFD700);
        break;
      case '8g':
        icon = Icons.radio_button_checked;
        color = const Color(0xFFFFA000);
        break;
      case '18k':
        icon = Icons.star;
        color = const Color(0xFFFF8F00);
        break;
      default:
        icon = Icons.monetization_on;
        color = const Color(0xFFFFD700);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getGoldTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case '1g':
        return '1 Gram';
      case '8g':
        return '8 Gram';
      case '18k':
        return '1 Gram';
      default:
        return type;
    }
  }

  String _getGoldLabel(String type) {
    switch (type.toLowerCase()) {
      case '1g':
        return '22 Karat';
      case '8g':
        return '22 Karat';
      case '18k':
        return '18 Karat';
      default:
        return type;
    }
  }

  Widget _buildLastUpdated() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Last updated: ${_getCurrentTime()}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCategoriesSection(List categories) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SwapableProductView(
                          category: (categories[index]['category']),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF7EE),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            image: DecorationImage(
                              image: NetworkImage(categories[index]["image"]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          categories[index]['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksSection(List<Map<String, dynamic>> links) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: links.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (_userName != "") {
                    if (links[index]['name'] == "Pay Now") {
                      final snackBar = SnackBar(
                        content: const Text("Currently not available...!"),
                      );

                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const MakePayment()));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionScreen(),
                        ),
                      );
                    }
                  } else {
                    const snackBar = SnackBar(
                      content: Text("Your not loggin...! Please Login"),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: links[index]['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          links[index]['icon'],
                          color: links[index]['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          links[index]['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreLocationsSection(List stores) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Stores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsPage(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF7EE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stores[index]['jewelleryName'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stores[index]['address'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF7EE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shop,
                              color: Color(0xFFFFB74D),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(List products) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length > 4 ? 4 : products.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwapableProductView(
                        category: products[index]['category'],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use placeholder instead of real image since we don't have assets
                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: products[index]['photo'] != ""
                              ? Image(
                                  image: NetworkImage(products[index]['photo']),
                                )
                              : Icon(
                                  FontAwesomeIcons.gem,
                                  size: 40,
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withOpacity(0.7),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              products[index]['productName'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFB74D),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${products[index]['productCode']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${products[index]['gram']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
