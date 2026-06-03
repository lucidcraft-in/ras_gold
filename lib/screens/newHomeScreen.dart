// ignore_for_file: file_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raz_gold/providers/goldrate.dart';
import 'package:raz_gold/screens/categoryScreen.dart';
import 'package:raz_gold/screens/makePayment.dart';
import 'package:raz_gold/screens/transaction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);
  static const Color _cream = Color(0xFFFFFCF7);

  final NumberFormat _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  Map<String, double> goldPrices = {'1g': 0.00, '8g': 0.00, '18K': 0.00};
  // Map<String, double> goldPrices = {};
  Map<String, double> goldChanges = {};
  Map<String, bool> goldUp = {};
  List categories = [];
  List stores = [];
  List products = [];
  List banner = [];
  List goldrateList = [];
  Map<String, dynamic> aboutUsData = {};
  Map<String, dynamic> _userData = {};
  String _userName = "";

  final List<Map<String, dynamic>> _fallbackCategories = const [
    {
      'name': 'Rings',
      'category': 'Rings',
      'asset': 'assets/images/ring image.jpg',
    },
    {
      'name': 'Bangles',
      'category': 'Bangles',
      'asset': 'assets/images/bracelet.jpg',
    },
    {
      'name': 'Necklaces',
      'category': 'Necklaces',
      'asset': 'assets/images/necklace.png',
    },
    {
      'name': 'Earrings',
      'category': 'Earrings',
      'asset': 'assets/images/gold earrings.jpg',
    },
  ];

  final List<Map<String, dynamic>> _fallbackProducts = const [
    {
      'productName': 'Gold Ring',
      'productCode': '22K',
      'gram': '₹24,520',
      'category': 'Rings',
      'asset': 'assets/images/ring image.jpg',
    },
    {
      'productName': 'Gold Bangles',
      'productCode': '22K',
      'gram': '₹48,750',
      'category': 'Bangles',
      'asset': 'assets/images/bracelet.jpg',
    },
    {
      'productName': 'Gold Necklace',
      'productCode': '22K',
      'gram': '₹1,25,300',
      'category': 'Necklaces',
      'asset': 'assets/images/necklace.png',
    },
    {
      'productName': 'Gold Earrings',
      'productCode': '22K',
      'gram': '₹18,680',
      'category': 'Earrings',
      'asset': 'assets/images/gold earrings.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    getUser();
    getSlider();
    getGoldrate();
    getCategory();
    getProduct();
    fetchData();
  }

  void getGoldrate() {
    Provider.of<Goldrate>(context, listen: false).read().then((value) {
      if (!mounted || value == null || value.isEmpty) return;

      final data = value[0];
      print(data);
      final double upValue = _toDouble(data["up"]);
      final double downValue = _toDouble(data["down"]);

      setState(() {
        goldrateList = value;

        goldPrices = {
          '1g': _toDouble(data["gram"]),
          '8g': _toDouble(data["pavan"]),
          '18K': _toDouble(data["18gram"]),
        };

        goldChanges = {
          '1g': upValue > 0 ? upValue : downValue,
          '8g': upValue > 0 ? upValue : downValue,
          '18K': 0,
        };

        goldUp = {
          '1g': upValue > 0,
          '8g': upValue > 0,
          '18K': false,
        };
      });
    });
  }

  void getSlider() {
    Provider.of<BannerProvider>(context, listen: false).getSlide('Banner').then(
      (onvalue) {
        if (!mounted) return;
        setState(() {
          banner = onvalue;
        });
      },
    );
    Provider.of<BannerProvider>(context, listen: false).fetchData().then((val) {
      if (!mounted) return;
      setState(() {
        stores = val;
      });
    });
  }

  Future<void> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (pref.containsKey("user")) {
      String? userData = pref.getString("user");
      if (userData != null) {
        Map<String, dynamic> user = json.decode(userData);
        setState(() {
          _userData = user;
          _userName = user['name'] ?? '';
        });
        await _refreshUserData(user);
      }
    } else {
      setState(() {
        _userName = '';
      });
    }
  }

  Future<void> _refreshUserData(Map<String, dynamic> savedUser) async {
    final String userId = '${savedUser['id'] ?? ''}'.trim();
    if (userId.isEmpty) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (!mounted || !doc.exists) return;

      final data = doc.data() ?? {};
      setState(() {
        _userData = {...savedUser, ...data, 'id': doc.id};
        _userName = '${_userData['name'] ?? ''}';
      });
      print("****************************");
      print(_userData);
      print("****************************");
    } catch (e) {
      debugPrint('Unable to refresh user details: $e');
    }
  }

  // void getGoldrate() {
  //   Provider.of<Goldrate>(context, listen: false).read().then((value) {
  //     if (!mounted || value == null || value.isEmpty) return;
  //     setState(() {
  //       goldrateList = value;
  //       print(goldrateList[0]);
  //       goldPrices = {
  //         '1g': _toDouble(goldrateList[0]["gram"]),
  //         '8g': _toDouble(goldrateList[0]["pavan"]),
  //         '18K': _toDouble(goldrateList[0]["18gram"]),
  //         'up': goldrateList[0]["up"],
  //         'down': goldrateList[0]["down"]
  //       };
  //     });
  //   });
  // }

  void getCategory() {
    Provider.of<Category>(context, listen: false).getCategory().then((onValue) {
      if (!mounted) return;
      setState(() {
        categories = onValue;
      });
    });
  }

  void getProduct() {
    Provider.of<Product>(context, listen: false).getProduct().then((onValue) {
      if (!mounted) return;
      setState(() {
        products = onValue ?? [];
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        products = [];
      });
    });
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('aboutUs').limit(1).get();

      if (!mounted || querySnapshot.docs.isEmpty) return;
      var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        aboutUsData = data;
      });
    } catch (e) {
      debugPrint('Unable to load store details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildHero(),
              const SizedBox(height: 14),
              _buildBalanceCard(),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 14),
              _buildGoldRateSection(),
              const SizedBox(height: 10),
              _buildSchemeProgress(),
              const SizedBox(height: 10),
              _buildCategoriesSection(),
              const SizedBox(height: 10),
              _buildProductsSection(),
              const SizedBox(height: 10),
              _buildStoreSection(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 132,
            fit: BoxFit.contain,
          ),
        ),
        const Spacer(),
        // _roundIcon(
        //   Icons.notifications_none_rounded,
        //   onTap: () {},
        //   showDot: true,
        // ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF1E7DA),
            child: Image(image: AssetImage("assets/images/face1.png")),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      height: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _cream,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bracelet.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: .92),
                    Colors.white.withValues(alpha: .35),
                  ],
                  stops: const [.0, .44, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 18,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 24,
                    height: 1.02,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Text(
                      'Your gold journey continues',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.star, color: _gold, size: 15),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final double balance = _customerBalance;
    final double fullAmount = _schemeFullAmount;
    final double totalGold = _toDouble(
      _userData['totalGram'] ?? _userData['total_gram'],
    );

    return _surface(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Total Gold Balance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.visibility_outlined, color: _gold, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalGold.toStringAsFixed(3),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        'g',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  'Gold in your scheme',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 62, color: _line),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invested Value',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _money.format(balance),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  fullAmount > 0
                      ? 'Target ${_money.format(fullAmount)}'
                      : 'Total invested amount',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _goldButton(
            label: 'Invest Now',
            icon: Icons.arrow_forward_rounded,
            onTap: _openPayment,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            title: 'Pay Now',
            subtitle: 'Make quick payments',
            icon: Icons.payments_outlined,
            filled: true,
            onTap: _openPayment,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionTile(
            title: 'View Transactions',
            subtitle: 'Check your history',
            icon: Icons.receipt_long_outlined,
            onTap: _openTransactions,
          ),
        ),
      ],
    );
  }

  Widget _buildGoldRateSection() {
    return _surface(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                "Today's Gold Rate",
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.circle, color: Color(0xFF34B56A), size: 9),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Live market prices',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              _LivePill(),
            ],
          ),
          const SizedBox(height: 14),
          // Row(
          //   children: [
          //     _rateCard(
          //       icon: FontAwesomeIcons.cubes,
          //       title: '22 Karat',
          //       subtitle: '1 Gram',
          //       value: goldPrices['1g'] ?? 0,
          //       change: '0.45%',
          //       up: true,
          //     ),
          //     const SizedBox(width: 10),
          //     _rateCard(
          //       icon: FontAwesomeIcons.ring,
          //       title: '22 Karat',
          //       subtitle: '8 Gram',
          //       value: goldPrices['8g'] ?? 0,
          //       change: '0.45%',
          //       up: true,
          //       popular: true,
          //     ),
          //     const SizedBox(width: 10),
          //     _rateCard(
          //       icon: Icons.star_rounded,
          //       title: '18 Karat',
          //       subtitle: '1 Gram',
          //       value: goldPrices['18K'] ?? 0,
          //       change: '0.20%',
          //       up: false,
          //     ),
          //   ],
          // ),

          Row(
            children: [
              _rateCard(
                icon: FontAwesomeIcons.cubes,
                title: '22 Karat',
                subtitle: '1 Gram',
                value: goldPrices['1g'] ?? 0,
                change: '${goldChanges['1g'] ?? 0}',
                up: goldUp['1g'] ?? true,
              ),
              const SizedBox(width: 10),
              _rateCard(
                icon: FontAwesomeIcons.ring,
                title: '22 Karat',
                subtitle: '8 Gram',
                value: goldPrices['8g'] ?? 0,
                change: '${goldChanges['8g'] ?? 0}',
                up: goldUp['8g'] ?? true,
                popular: true,
              ),
              const SizedBox(width: 10),
              _rateCard(
                icon: Icons.star_rounded,
                title: '18 Karat',
                subtitle: '1 Gram',
                value: goldPrices['18K'] ?? 0,
                change: '',
                up: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: _muted),
              const SizedBox(width: 5),
              Text(
                'Last updated: ${_updatedAtLabel()}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeProgress() {
    final double progress = _schemeProgress;
    final int percent = (progress * 100).round();
    final int paidMonths = _paidMonths;
    final double fullAmount = _schemeFullAmount;
    print("======================");
    print('progress $progress');
    print('fullAmount $fullAmount');
    print('paidMonths $paidMonths');
    print('percent $percent');
    return _surface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFEFE8DE),
                  valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Scheme Progress',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fullAmount > 0
                      ? '$paidMonths of 12 months paid'
                      : 'Set monthly limit to track progress',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEFE8DE),
                    valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next due date',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
              const SizedBox(height: 5),
              Text(
                _nextDueDate(),
                style: const TextStyle(
                  color: _deepGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EFE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: _gold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final shown = categories.isEmpty ? _fallbackCategories : categories;
    return _surface(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        children: [
          _sectionTitle(
            'Categories',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: shown.length > 8 ? 8 : shown.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = shown[index];
                return _categoryCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    final shown = products.isEmpty ? _fallbackProducts : products;
    return _surface(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          _sectionTitle(
            'Featured Products',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: shown.length > 8 ? 8 : shown.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _productCard(shown[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    final store = stores.isNotEmpty ? stores.first : null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      ),
      child: _surface(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5DE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_outlined, color: _gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Our Stores',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    store?['jewelleryName'] ?? 'Ras Gold & Diamonds',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        '3+ Branches Near You',
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: _gold),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          store?['address'] ?? 'Kozhikode, Kerala',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'View Store',
              style: TextStyle(
                color: _deepGold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: _ink),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.receipt_long_outlined, 'My Schemes'),
      (Icons.shopping_bag_outlined, 'Gold Purchase'),
      (Icons.local_offer_outlined, 'Offers'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final selected = index == 0;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _handleNavTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].$1,
                        color: selected ? _gold : const Color(0xFF5E5E5E),
                        size: 23,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? _gold : const Color(0xFF5E5E5E),
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _surface({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _roundIcon(
    IconData icon, {
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _ink),
          ),
          if (showDot)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _goldButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD6AB47), Color(0xFFBF8F28)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: filled ? null : Colors.white,
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFFDBB458), Color(0xFFB98827)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: _line),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _gold.withValues(alpha: .22),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: filled ? Colors.white : _gold, size: 32),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filled ? Colors.white : _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filled ? Colors.white : _muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: filled ? Colors.white : _ink,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required String change,
    required bool up,
    bool popular = false,
  }) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 166),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: popular ? _gold : _line),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _gold, size: 24),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _money.format(value),
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(
                //       up
                //           ? Icons.arrow_upward_rounded
                //           : Icons.arrow_downward_rounded,
                //       color: up ? const Color(0xFF34A853) : Colors.red,
                //       size: 16,
                //     ),
                //     const SizedBox(width: 3),
                //     Text(
                //       change,
                //       style: TextStyle(
                //         color: up ? const Color(0xFF34A853) : Colors.red,
                //         fontSize: 12,
                //         fontWeight: FontWeight.w700,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 6),

                if (change.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        up
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: up ? const Color(0xFF34A853) : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        change,
                        style: TextStyle(
                          color: up ? const Color(0xFF34A853) : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
          if (popular)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {required VoidCallback onTap}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: _deepGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: _ink, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(dynamic item) {
    final String name = '${item['name'] ?? item['category'] ?? 'Category'}';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SwapableProductView(
            category: '${item['category'] ?? name}',
          ),
        ),
      ),
      child: Container(
        width: 116,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
                child: _dataImage(
                  item,
                  height: 68,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(dynamic item) {
    final String name = '${item['productName'] ?? 'Gold Product'}';
    final String category = '${item['category'] ?? name}';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SwapableProductView(category: category),
        ),
      ),
      child: Container(
        width: 136,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 76,
                  width: double.infinity,
                  child: _dataImage(item, height: 76, fit: BoxFit.contain),
                  // ),
                  // const Positioned(
                  //   right: 0,
                  //   top: 0,
                  //   child: Icon(Icons.favorite_border, color: _gold, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${item['productCode'] ?? '22K'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _ink, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _productPrice(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _deepGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataImage(dynamic item, {required double height, BoxFit? fit}) {
    final String? url = item['image'] ?? item['photo'];
    final String? asset = item['asset'];
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(height),
      );
    }
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(height),
      );
    }
    return _imageFallback(height);
  }

  Widget _imageFallback(double height) {
    return SizedBox(
      height: height,
      child: const Center(
        child: Icon(FontAwesomeIcons.gem, color: _gold, size: 28),
      ),
    );
  }

  void _openPayment() {
    // if (_userName.isNotEmpty) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const MakePayment()),
    //   );
    //   return;
    // }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Please login to make a payment")),
    // );
    final messenger = ScaffoldMessenger.of(context);

    // Navigator.pop(context);

    messenger.showSnackBar(
      const SnackBar(content: Text("Under development")),
    );
  }

  void _openTransactions() {
    if (_userName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TransactionScreen()),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login to view transactions")),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) return;
    if (index == 1) {
      _openTransactions();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  String _productPrice(dynamic item) {
    final dynamic gram = item['gram'];
    if (gram == null) return 'View';
    final text = '$gram';
    if (text.contains('₹')) return text;
    final number = double.tryParse(text);
    if (number == null) return text;
    return '${number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2)}g';
  }

  String _updatedAtLabel() {
    if (goldrateList.isNotEmpty) {
      final time = '${goldrateList[0]['updateTime'] ?? ''}'.trim();
      if (time.isNotEmpty) return time;
    }
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _nextDueDate() {
    final createdAt = _customerCreatedAt;
    if (createdAt == null) return '-';

    final now = DateTime.now();
    DateTime dueDate = _dateWithCustomerDay(now.year, now.month, createdAt.day);
    if (!dueDate.isAfter(now)) {
      dueDate = _dateWithCustomerDay(now.year, now.month + 1, createdAt.day);
    }
    return DateFormat('dd MMM yyyy').format(dueDate);
  }

  String get _displayName {
    if (_userName.trim().isEmpty) return 'Guest';
    return _userName.trim().split(' ').first;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  double get _customerBalance => _toDouble(_userData['balance']);

  // double get _monthlyLimit => _toDouble(_userData['limit']);
  double get _monthlyLimit {
    final limit = '${_userData['limit'] ?? ''}'.trim();

    if (limit.contains('-')) {
      return double.tryParse(limit.split('-').first.trim()) ?? 0;
    }

    return double.tryParse(limit) ?? 0;
  }

  double get _schemeFullAmount => _monthlyLimit * 12;

  double get _schemeProgress {
    print(_customerBalance);
    print(_schemeFullAmount);
    final fullAmount = _schemeFullAmount;
    if (fullAmount <= 0) return 0;
    return (_customerBalance / fullAmount).clamp(0.0, 1.0);
  }

  int get _paidMonths {
    final limit = _monthlyLimit;
    if (limit <= 0) return 0;
    return (_customerBalance / limit).floor().clamp(0, 12);
  }

  DateTime? get _customerCreatedAt {
    final value = _userData['timestamp'] ??
        _userData['createdAt'] ??
        _userData['createDate'] ??
        _userData['createdDate'];

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime _dateWithCustomerDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = day.clamp(1, lastDay);
    return DateTime(year, month, safeDay);
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF34B56A), size: 7),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFF22964C),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
