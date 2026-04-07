import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/phonePe_payment.dart';
import '../providers/staff.dart';
import '../providers/transaction.dart';
import 'login_screen.dart';
import 'paymentResponseScreen.dart';

enum PaymentState { idle, validating, processing, success, failed }

class MakePayment extends StatefulWidget {
  const MakePayment({super.key});

  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment>
    with TickerProviderStateMixin {
  late Razorpay razorpay;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  double finalAmount = 0;

  // Enhanced loading states
  bool isProcessing = false;
  bool isValidating = false;
  bool isAmountValid = false;
  String validationError = '';

  // Payment states

  PaymentState currentState = PaymentState.idle;

  @override
  void initState() {
    checkUser();
    setupAnimations();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, errorHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, successHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, externalWalletHandler);
    super.initState();
  }

  void setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  // Enhanced validation
  void validateAmount(String value) {
    setState(() {
      isValidating = true;
      validationError = '';
    });

    // Simulate validation delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (value.isEmpty) {
            isAmountValid = false;
            validationError = '';
          } else {
            double? amount = double.tryParse(value);
            if (amount == null) {
              isAmountValid = false;
              validationError = 'Please enter a valid amount';
            } else if (amount <= 0) {
              isAmountValid = false;
              validationError = 'Amount must be greater than ₹0';
            } else if (amount < 1) {
              isAmountValid = false;
              validationError = 'Minimum amount is ₹1';
            } else if (amount > 100000) {
              isAmountValid = false;
              validationError = 'Maximum amount is ₹1,00,000';
            } else {
              isAmountValid = true;
              finalAmount = amount;
              validationError = '';
            }
          }
          isValidating = false;
        });
      }
    });
  }

  void errorHandler(PaymentFailureResponse response) {
    setState(() {
      currentState = PaymentState.failed;
      isProcessing = false;
    });

    var db = phonePe_Payment();
    db.initiliase();
    db.updateTransaction(orderId, "Failed");

    var res = {
      "code": "Failed",
      "amount": amountController.text,
      "type": "online",
      "transactionId": orderId
    };

    // Enhanced error dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Payment Failed',
          text: response.message ?? 'Something went wrong. Please try again.',
          confirmBtnColor: Colors.red,
          confirmBtnTextStyle: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
          onConfirmBtnTap: () {
            if (!mounted) return;
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ResponseScreen(response: res),
            //   ),
            // );
          });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(response.message ?? 'Payment failed')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void successHandler(PaymentSuccessResponse response) {
    setState(() {
      currentState = PaymentState.success;
    });

    var db = phonePe_Payment();
    db.initiliase();
    db.updateTransaction(orderId, "Success");

    var res = {
      "code": "PAYMENT_SUCCESS",
      "amount": amountController.text,
      "type": "online",
      "transactionId": orderId
    };

    addTransaction(res);

    // Enhanced success dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Payment Successful!',
          text: '₹${amountController.text} paid successfully',
          confirmBtnColor: Colors.green,
          confirmBtnTextStyle: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
          onConfirmBtnTap: () {
            if (!mounted) return;
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ResponseScreen(response: res),
            //   ),
            // );
          });
    });

    setState(() {
      isProcessing = false;
    });
  }

  void externalWalletHandler(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: 8),
              Text('Redirected to ${response.walletName}'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  var userData;
  String custId = "";
  String userName = "";
  String mobileNo = "";

  Future checkUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userJson = pref.getString("user");
    if (userJson == null) {
      if (mounted) clearData();
      return;
    }
    var decodedJson = json.decode(userJson);
    userData = decodedJson;

    // Safety fallback for missing ID if user didn't log out
    if (userData["id"] == null && userData["custId"] != null) {
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('custId', isEqualTo: userData['custId'])
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          userData["id"] = snapshot.docs.first.id;
          pref.setString(
              "user",
              json.encode(userData, toEncodable: (item) {
                if (item is Timestamp) {
                  return item.toDate().toIso8601String();
                }
                return item;
              }));
        }
      } catch (e) {}
    }

    setState(() {
      custId = userData["custId"];
      userName = userData["name"];
      mobileNo = userData["phoneNo"];
    });
  }

  Staff? db;
  List staffList = [];
  List filterList = [];
  String adminToken = "";

  getAdminStaff() async {
    db = Staff();
    db!.initiliase();
    db!.read().then((value) => {
          setState(() {
            staffList = value!;
          }),
        });

    if (staffList.isNotEmpty) {
      filterList = staffList
          .where((element) => (element['type'].toString().contains("1")))
          .toList();

      if (filterList.isNotEmpty) {
        setState(() {
          adminToken = filterList[0]["token"] ?? "";
        });
      }
    }
  }

  clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.getKeys();
    for (String key in preferences.getKeys()) {
      preferences.remove(key);
    }
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    amountController.dispose();
    noteController.dispose();
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Payment",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // User greeting section
                _buildUserGreeting(),

                const SizedBox(height: 40),
                const SizedBox(
                  height: 10,
                ),
                Text("Amount Limit : Rs. ${userData["limit"]}"),
                // Amount input section
                _buildAmountInput(),

                const SizedBox(height: 20),

                // Note input section
                _buildNoteInput(),

                const SizedBox(height: 30),

                // Amount summary
                _buildAmountSummary(),

                const SizedBox(height: 40),

                // Pay button with loading states
                _buildPayButton(),

                const SizedBox(height: 20),

                // Security info
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGreeting() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text("Hello",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 5),
              Text(
                userData != null ? userName.toUpperCase() : "Guest",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image(
                    height: 25,
                    image: const AssetImage(
                        "assets/images/Rupee-Symbol-Black.png"),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: amountController,
                    readOnly: isProcessing,
                    onChanged: validateAmount,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: isAmountValid ? Colors.black : Colors.grey[600],
                    ),
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (isValidating)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),

          // Validation error
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: validationError.isNotEmpty ? 25 : 0,
            child: validationError.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        validationError,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: noteController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: "Add a note (optional)",
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Icons.note_add_outlined, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    if (!isAmountValid || amountController.text.isEmpty)
      return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Amount", style: TextStyle(color: Colors.grey[600])),
              Row(
                children: [
                  const Image(
                    height: 12,
                    image: AssetImage("assets/images/Rupee-Symbol-Black.png"),
                    color: Colors.black,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    amountController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Row(
                children: [
                  Image(
                    height: 14,
                    image: const AssetImage(
                        "assets/images/Rupee-Symbol-Black.png"),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    amountController.text,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    bool canPay = isAmountValid && !isProcessing && !isValidating;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: canPay
            ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              )
            : null,
        color: canPay ? null : Colors.grey.shade300,
        boxShadow: canPay
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: canPay ? _handlePayment : null,
          child: Center(
            child: isProcessing
                ? _buildProcessingIndicator()
                : Text(
                    _getButtonText(),
                    style: TextStyle(
                      color: canPay ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _getProcessingText(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getButtonText() {
    if (amountController.text.isEmpty || !isAmountValid) {
      return "Enter amount to pay";
    }
    return "Pay ₹${amountController.text}";
  }

  String _getProcessingText() {
    switch (currentState) {
      case PaymentState.validating:
        return "Validating...";
      case PaymentState.processing:
        return "Processing...";
      default:
        return "Please wait...";
    }
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Your payment is secured with 256-bit SSL encryption",
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePayment() {
    FocusScope.of(context).unfocus();
    if (!isAmountValid) return;
    final limitStr = userData["limit"]?.toString() ?? "";
    final currentAmount = double.tryParse(amountController.text) ?? 0;

    if (limitStr.contains("-")) {
      List<String> parts = limitStr.split("-");
      if (parts.length == 2) {
        double minLimit = double.tryParse(parts[0].trim()) ?? 0;
        double maxLimit = double.tryParse(parts[1].trim()) ?? double.infinity;

        if (currentAmount < minLimit || currentAmount > maxLimit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Amount should be between ₹${minLimit.toInt()} and ₹${maxLimit.toInt()}!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    } else {
      double fixedLimit = double.tryParse(limitStr) ?? 0;
      if (currentAmount != fixedLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Amount should be Fixed limit: ₹${fixedLimit.toInt()}!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isProcessing = true;
      currentState = PaymentState.processing;
    });

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    submit();
  }

  String url = "https://api-eyf2rrsnrq-uc.a.run.app/api/create-order";
  String orderId = "";

  submit() async {
    setState(() {
      currentState = PaymentState.validating;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "amount": (finalAmount * 100).toInt(),
          "currency": "INR",
          "receipt": "receipt#1",
          "partial_payment": false,
          "notes": {
            "key1": noteController.text,
            "key2": "value2",
          }
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        orderId = responseData['order']['id'];

        var data = {
          "custId": custId,
          "TransactionId": orderId,
          "custName": userName,
          "amount": finalAmount,
          "note": noteController.text,
          "custPhone": mobileNo,
        };

        firebaseInsert(data);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isProcessing = false;
        currentState = PaymentState.failed;
      });
      _pulseController.stop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to initiate payment. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  firebaseInsert(var data) {
    var db = phonePe_Payment();
    db.initiliase();
    db.addTransaction(data).then((value) {
      openCheckout(data["TransactionId"]);
    });
  }

  openCheckout(String orderId) {
    // Simplest possible options to rule out parsing issues on iOS
    var options = {
      "key": "rzp_live_RFRiy6xrGiTaa8",
      "amount": (finalAmount * 100).toInt(),
      "name": "Munawara Gold",
      'order_id': orderId,
      "currency": "INR",
      "timeout": 300,
      "prefill": {"contact": mobileNo, "email": "customer@example.com"},
      "theme": {
        "color": "#000000" // Use a solid black or primary color
      },
      "retry": {"enabled": true, "max_count": 1},
      "send_sms_hash": true,
      "readonly": {"contact": true, "email": true}
    };

    try {
      razorpay.open(options);
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && isProcessing) {
          setState(() {
            isProcessing = false;
            currentState = PaymentState.idle;
          });
        }
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
        currentState = PaymentState.failed;
      });
      _pulseController.stop();
    }
  }

  addTransaction(var response) async {
    var data = TransactionModel(
        id: "",
        customerName: userName,
        customerId: userData["id"],
        date: DateTime.now(),
        amount: double.parse(response["amount"].toString()),
        transactionType: 0,
        note: noteController.text,
        invoiceNo: response["transactionId"],
        category: "GOLD",
        discount: 0,
        staffId: "",
        branch: 0,
        gramPriceInvestDay: 0.0,
        gramWeight: 0.0,
        merchentTransactionId: response["transactionId"],
        transactionMode: "online");

    var db = Transaction();
    db.initiliase();
    db.create(data).then((value) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Transaction Added Successfully"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }
}
