import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/banner.dart';
import 'providers/category.dart';
import 'providers/goldrate.dart';
import 'providers/payment.dart';
import 'providers/paymentBill.dart';
import 'providers/phonePe_payment.dart';
import 'providers/product.dart';
import 'providers/staff.dart';
import 'providers/transaction.dart';
import 'providers/user.dart';
import 'screens/newHomeScreen.dart';

class GoldJewelryApp extends StatelessWidget {
  const GoldJewelryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => User(),
        ),
        ChangeNotifierProvider(
          create: (_) => Transaction(),
        ),
        ChangeNotifierProvider(
          create: (_) => Goldrate(),
        ),
        ChangeNotifierProvider(
          create: (_) => Product(),
        ),
        ChangeNotifierProvider(
          create: (_) => Payment(),
        ),
        ChangeNotifierProvider(
          create: (_) => Staff(),
        ),
        ChangeNotifierProvider(
          create: (_) => BannerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => phonePe_Payment(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentBillProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Category(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gold Jewelry Store',
        theme: ThemeData(
          primaryColor: const Color(0xFF4CAF50),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xFF4CAF50)),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4CAF50),
            secondary: Color(0xFF81C784),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
