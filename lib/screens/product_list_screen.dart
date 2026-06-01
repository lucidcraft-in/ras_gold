// import 'package:flutter/material.dart';

// import '../screens/productView.dart';
// import '../providers/product.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductListScreen extends StatefulWidget {
//   static const routeName = '/product-screen';
//   const ProductListScreen({super.key, this.category});
//   final String? category;

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   bool isSelect = true;
//   var selectItem = [];
//   Stream? products;
//   String branchName = "";
//   Product? db;
//   List userList = [];
//   CollectionReference collectionReference =
//       FirebaseFirestore.instance.collection('product');

//   Stream? _queryDb() {
//     products = FirebaseFirestore.instance
//         .collection('product')
//         .where("category", isEqualTo: CategoryName)
//         .snapshots()
//         .map(
//           (list) => list.docs.map((doc) => doc.data()),
//         );
//     return null;
//   }

//   String capitalizeAllWord(String value) {
//     var result = value[0].toUpperCase();
//     for (int i = 1; i < value.length; i++) {
//       if (value[i - 1] == " ") {
//         result = result + value[i].toUpperCase();
//       } else {
//         result = result + value[i];
//       }
//     }
//     return result;
//   }

//   String? CategoryName;
//   initialise() {
//     setState(() {
//       CategoryName = widget.category;
//     });

//     db = Product();
//     db!.initiliase();
//     db!.read(CategoryName!).then((value) => {
//           setState(() {
//             userList = value ?? userList;
//           }),
//           // print("---------------------"),
//         });
//   }

//   @override
//   void initState() {
//     _queryDb();
//     super.initState();
//     initialise();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
//     final double itemWidth = size.width / 2;
//     return Scaffold(
//         appBar: AppBar(
//           iconTheme: const IconThemeData(color: Colors.black),
//           backgroundColor: Theme.of(context).primaryColor,
//           title: const Text(
//             'Products',
//           ),
//         ),
//         body: userList.isNotEmpty
//             ? Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: MediaQuery.of(context).size.width /
//                         (MediaQuery.of(context).size.height / 1.98),
//                     mainAxisSpacing: 5.0,
//                     crossAxisSpacing: 5.0,
//                   ),
//                   itemCount: userList.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     // print(userList[index]['branch']);
//                     if (userList[index]['branch'] == 0) {
//                       branchName = "Alathur";
//                     } else if (userList[index]['branch'] == 1) {
//                       branchName = "Chittur";
//                     } else if (userList[index]['branch'] == 2) {
//                       branchName = "Vadakkencherri";
//                     }
//                     // print(branchName);

//                     return userList != null
//                         ? GestureDetector(
//                             onTap: () {
//                               // print(userList[index]);
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => SwapableProductView(
//                                             category: CategoryName!,
//                                           )));
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color:
//                                       const Color.fromARGB(255, 229, 221, 229),
//                                   borderRadius: BorderRadius.circular(15)),
//                               padding: const EdgeInsets.all(10),
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: Image(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               .18,
//                                       image: NetworkImage(
//                                           userList[index]["photo"]),
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null) {
//                                           return child;
//                                         }
//                                         return SizedBox(
//                                             height: 20,
//                                             width: 20,
//                                             child: CircularProgressIndicator(
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                             ));
//                                       },
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return const Text(
//                                             'Error loading image');
//                                       },
//                                     ),

//                                     //  Image.network(
//                                     //   userList[index]["photo"],
//                                     //   fit: BoxFit.contain,
//                                     //   height:
//                                     //       MediaQuery.of(context).size.height *
//                                     //           .18,
//                                     // ),
//                                   ),
//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   Container(
//                                     child: Flexible(
//                                       child: Text(
//                                         userList[index]['productName'] != null
//                                             ? capitalizeAllWord(
//                                                 userList[index]['productName'],
//                                               )
//                                             : userList[index]['productName'],
//                                         style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w400,
//                                             overflow: TextOverflow.ellipsis),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         : const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                     //   },
//                     // );
//                   },
//                 ),
//               )
//             : const Center(
//                 child: Text("No data found it this category...."),
//               ));
//   }
// }

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../screens/productView.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/product-screen';

  const ProductListScreen({
    super.key,
    this.category,
  });

  final String? category;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const Color _gold = Color(0xFFC89A32);
  static const Color _deepGold = Color(0xFF9F741E);
  static const Color _ink = Color(0xFF171717);
  static const Color _muted = Color(0xFF6E6559);
  static const Color _line = Color(0xFFEAE2D3);

  Product? db;

  List userList = [];

  String? categoryName;

  @override
  void initState() {
    super.initState();
    initialise();
  }

  void initialise() {
    setState(() {
      categoryName = widget.category;
    });

    db = Product();
    db!.initiliase();

    db!.read(categoryName!).then((value) {
      if (!mounted) return;

      setState(() {
        userList = value ?? [];
      });
    });
  }

  String capitalizeAllWord(String value) {
    if (value.isEmpty) return value;

    var result = value[0].toUpperCase();

    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result += value[i].toUpperCase();
      } else {
        result += value[i];
      }
    }

    return result;
  }

  String getBranchName(dynamic branch) {
    switch (branch) {
      case 0:
        return "Alathur";
      case 1:
        return "Chittur";
      case 2:
        return "Vadakkencherri";
      default:
        return "Branch";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
        title: const Text(
          "Products",
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: userList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: userList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: .68,
                ),
                itemBuilder: (context, index) {
                  return _productCard(index);
                },
              ),
            )
          : _emptyState(),
    );
  }

  Widget _productCard(int index) {
    final product = userList[index];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print(categoryName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SwapableProductView(
              category: categoryName!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  product["photo"] ?? "",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        color: _gold,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFFFFF7E8),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: _gold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      capitalizeAllWord(
                        product["productName"] ?? "",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFFFFF7E8),
                    //     borderRadius: BorderRadius.circular(6),
                    //   ),
                    //   child: Text(
                    //     getBranchName(product["branch"]),
                    //     style: const TextStyle(
                    //       color: _deepGold,
                    //       fontWeight: FontWeight.w700,
                    //       fontSize: 11,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: const Text(
          "No Products Found",
          style: TextStyle(
            color: _muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
