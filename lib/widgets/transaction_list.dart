import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Providers/transaction.dart';
import '../screens/uploadPaymentImage/sendPaymentRecipt.dart';

class TransactionList extends StatefulWidget {
  static const routeName = "/transaction_list";

  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var selectedIndex = -1;
  bool isClick = false;
  dynamic user;
  Transaction? db;
  List transactionList = [];
  double customerBalance = 0;
  double totalGram = 0;
  List alllist = [];

  Map<String, double> userBalance = {
    'Invested Amount': 0.00,
    'Invested Gold': 0.000
  };

  int _expandedIndex = -1;
  double averageGramRate = 0;
  Set<int> selectedTransactions = {};

  initialise() {
    db = Transaction();
    db!.initiliase();

    db!.read(user['id']).then((value) {
      setState(() {
        alllist = value!;
        transactionList = alllist[0];
        userBalance = {
          'Invested Amount': alllist[1],
          'Invested Gold': alllist[2],
        };
      });
      printSelectedTransactions();
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = jsonDecode(prefs.getString('user')!);
    await initialise();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildUserBalanceSection(userBalance),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SendPaymentRec()));
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
                        color: const Color(0xFFF06292).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Color(0xFFF06292),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: const Row(
              children: [
                Text(
                  "Transaction List",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: transactionList.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      DateTime myDateTime =
                          (transactionList[index]['date']).toDate();
                      bool isExpanded = index == _expandedIndex;
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            height: 35,
                            color: Colors.grey.shade300,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                DateFormat.yMMMd()
                                    .format(myDateTime)
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedIndex =
                                    _expandedIndex == index ? -1 : index;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(41, 154, 106, 156),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: transactionList[index]
                                                        ['transactionType'] ==
                                                    0
                                                ? const Color(0xFFdbdfde)
                                                : const Color.fromARGB(
                                                    255, 247, 216, 210),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            transactionList[index]
                                                        ['transactionType'] ==
                                                    0
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            color: transactionList[index]
                                                        ['transactionType'] ==
                                                    0
                                                ? const Color(0xFF69948f)
                                                : const Color(0xFFb84d3f),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${transactionList[index]['note']}  "
                                                        .toUpperCase(),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    transactionList[index][
                                                                'transactionMode'] ==
                                                            "online"
                                                        ? "Online Payment"
                                                        : transactionList[index]
                                                                    [
                                                                    'transactionMode'] ==
                                                                "Payment Proof"
                                                            ? "Accept Screenshot"
                                                            : "Direct",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: "latto",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          221, 47, 144, 37),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons
                                                          .indianRupeeSign,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      transactionList[index]
                                                              ['amount']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    if (isExpanded)
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Gram Price  : ${transactionList[index]['gramPriceInvestDay'].toString()}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "Gram Weight  :  ${transactionList[index]['gramWeight'].toString()}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    if (transactionList[index]
                                            ['transactionMode'] ==
                                        "online")
                                      Text(
                                        "Transaction Id : ${transactionList[index]['merchentTransactionId']}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: "latto",
                                          color:
                                              Color.fromARGB(221, 41, 42, 41),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    itemCount: transactionList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                  )
                : const Center(child: Text("No Transaction available yet")),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBalanceSection(Map<String, double> balance) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black87, Colors.black54],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: balance.entries.map((entry) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key == 'Invested Amount'
                            ? 'Rs. ${entry.value.toStringAsFixed(2)}'
                            : '${entry.value.toStringAsFixed(3)} gm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Average Gram Rate: ${averageGramRate.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void printSelectedTransactions() {
    setState(() {
      List selectedTransactionData = transactionList;
      averageGramRate = calculateAverageGramRate(selectedTransactionData);
    });
  }

  double calculateAverageGramRate(List selectedTransactions) {
    if (selectedTransactions.isEmpty) return 0.0;

    double totalGramPrice = selectedTransactions
        .map((transaction) => transaction['gramPriceInvestDay'] as double)
        .reduce((a, b) => a + b);

    return totalGramPrice / selectedTransactions.length;
  }
}
