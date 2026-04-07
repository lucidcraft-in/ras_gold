import 'package:flutter/material.dart';

import '../providers/category.dart';
import '../screens/product_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  var categoryDb = Category();
  var categoryList = [];
  Future loadCategoary() async {
    categoryDb.initiliase();
    categoryDb.getCategorywithImg().then((value) {
      // print(value);
      setState(() {
        categoryList = value;
      });
      // print(categoryList);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategoary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
  backgroundColor: const Color(0xFF460218),
  elevation: 2,
  centerTitle: true,

  // base icon color (must be white)
  iconTheme: const IconThemeData(color: Colors.white),

  //  Title gradient
  title: ShaderMask(
    shaderCallback: (bounds) => LinearGradient(
      colors: [
        Color(0xFFedc860),
        Color(0xFFd89f32),
        Color(0xFFe1b753),
      ],
    ).createShader(bounds),
    child: const Text(
      "Category",
      style: TextStyle(
        color: Colors.white, // must
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),

  //  Back icon gradient
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
      body: categoryList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListScreen(
                                                  category: categoryList[index]
                                                      ["name"])));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * .12,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .045,
                                                child: const Image(
                                                  height: 15,
                                                  width: 28,
                                                  color: Colors.black54,
                                                  image: AssetImage(
                                                      "assets/images/icons8-jewelry-64.png"),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                categoryList[index]["name"],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          const Text(
                                            "Tap to Show Product",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        );
                      })))
          : const Center(child: Text("No Category Found....")),
    );
  }
}
